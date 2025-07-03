package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;

@WebServlet("/LikeServlet")
public class LikeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("text/plain");
        PrintWriter out = res.getWriter();
        HttpSession session = req.getSession();

        Integer uid = (Integer) session.getAttribute("user_id");
        if (uid == null) {
            out.print("unauthorized");
            return;
        }

        String postIdStr = req.getParameter("post_id");
        if (postIdStr == null || postIdStr.trim().isEmpty()) {
            out.print("invalid_post_id");
            return;
        }

        int postId = Integer.parseInt(postIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            // 🔍 Check if already liked
            PreparedStatement check = conn.prepareStatement("SELECT * FROM likes WHERE user_id = ? AND post_id = ?");
            check.setInt(1, uid);
            check.setInt(2, postId);
            ResultSet rs = check.executeQuery();

            if (rs.next()) {
                // 🧹 Already liked → remove like
                PreparedStatement del = conn.prepareStatement("DELETE FROM likes WHERE user_id = ? AND post_id = ?");
                del.setInt(1, uid);
                del.setInt(2, postId);
                del.executeUpdate();
                out.print("unliked");
            } else {
                // ❤️ Not liked yet → insert like
                PreparedStatement insert = conn.prepareStatement("INSERT INTO likes (user_id, post_id) VALUES (?, ?)");
                insert.setInt(1, uid);
                insert.setInt(2, postId);
                insert.executeUpdate();
                out.print("liked");

                // 🔔 Insert notification if not liking own post
                PreparedStatement ownerStmt = conn.prepareStatement("SELECT user_id FROM posts WHERE id = ?");
                ownerStmt.setInt(1, postId);
                ResultSet ownerRs = ownerStmt.executeQuery();

                if (ownerRs.next()) {
                    int postOwnerId = ownerRs.getInt("user_id");
                    if (postOwnerId != uid) {
                        PreparedStatement notifyStmt = conn.prepareStatement(
                            "INSERT INTO notifications (user_id, receiver_id, post_id, type, message, is_seen, created_at) VALUES (?, ?, ?, ?, ?, 0, NOW())"
                        );
                        notifyStmt.setInt(1, uid);  // who liked
                        notifyStmt.setInt(2, postOwnerId);  // who receives
                        notifyStmt.setInt(3, postId);
                        notifyStmt.setString(4, "like");
                        notifyStmt.setString(5, "❤️ liked your post");
                        notifyStmt.executeUpdate();
                        notifyStmt.close();
                    }
                }

                ownerRs.close();
                ownerStmt.close();
            }

            rs.close();
            check.close();

        } catch (Exception e) {
            e.printStackTrace();
            out.print("error");
        }
    }
}
