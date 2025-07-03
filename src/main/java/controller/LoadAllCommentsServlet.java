package controller;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;

@WebServlet("/LoadAllCommentsServlet")
public class LoadAllCommentsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("text/plain");
        HttpSession session = req.getSession();

        Integer uid = (Integer) session.getAttribute("user_id");
        if (uid == null) {
            res.getWriter().print("unauthorized");
            return;
        }

        String comment = req.getParameter("comment");
        String postIdStr = req.getParameter("post_id");

        if (comment == null || comment.trim().isEmpty() || postIdStr == null || postIdStr.trim().isEmpty()) {
            res.getWriter().print("invalid");
            return;
        }

        int postId = Integer.parseInt(postIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            // 📝 Insert the comment
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO comments (post_id, user_id, content) VALUES (?, ?, ?)"
            );
            ps.setInt(1, postId);
            ps.setInt(2, uid);
            ps.setString(3, comment.trim());
            ps.executeUpdate();
            ps.close();

            // 🔍 Get post owner to send notification
            PreparedStatement ownerStmt = conn.prepareStatement("SELECT user_id FROM posts WHERE id = ?");
            ownerStmt.setInt(1, postId);
            ResultSet ownerRs = ownerStmt.executeQuery();

            if (ownerRs.next()) {
                int postOwnerId = ownerRs.getInt("user_id");
                if (postOwnerId != uid) {
                    // 🛎️ Send notification to post owner
                    PreparedStatement notifyStmt = conn.prepareStatement(
                        "INSERT INTO notifications (user_id, receiver_id, post_id, type, message, is_seen, created_at) VALUES (?, ?, ?, ?, ?, 0, NOW())"
                    );
                    notifyStmt.setInt(1, uid);  // who commented
                    notifyStmt.setInt(2, postOwnerId);  // who receives
                    notifyStmt.setInt(3, postId);
                    notifyStmt.setString(4, "comment");
                    notifyStmt.setString(5, "💬 commented on your post");
                    notifyStmt.executeUpdate();
                    notifyStmt.close();
                }
            }

            ownerRs.close();
            ownerStmt.close();

            res.getWriter().print("success");

        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().print("error");
        }
    }
}
