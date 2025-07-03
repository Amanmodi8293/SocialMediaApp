package controller;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;

@WebServlet("/FollowServlet")
public class FollowServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("text/plain");
        HttpSession session = req.getSession();
        Integer followerId = (Integer) session.getAttribute("user_id");
        int followingId = Integer.parseInt(req.getParameter("following_id"));
        boolean isFollowing = false;

        try (Connection conn = DBConnection.getConnection()) {
            // Check if already following
            PreparedStatement check = conn.prepareStatement(
                "SELECT id FROM follows WHERE follower_id=? AND following_id=?"
            );
            check.setInt(1, followerId);
            check.setInt(2, followingId);
            ResultSet rs = check.executeQuery();

            if (rs.next()) {
                // Unfollow
                PreparedStatement del = conn.prepareStatement(
                    "DELETE FROM follows WHERE follower_id=? AND following_id=?"
                );
                del.setInt(1, followerId);
                del.setInt(2, followingId);
                del.executeUpdate();
            } else {
                // Follow
                PreparedStatement insert = conn.prepareStatement(
                    "INSERT INTO follows (follower_id, following_id) VALUES (?, ?)"
                );
                insert.setInt(1, followerId);
                insert.setInt(2, followingId);
                insert.executeUpdate();
                isFollowing = true;

                // Insert notification if not self-following
                if (!followerId.equals(followingId)) {
                    String message = "👤 followed you";
                    PreparedStatement notifyStmt = conn.prepareStatement(
                        "INSERT INTO notifications (user_id, receiver_id, message, type) VALUES (?, ?, ?, ?)"
                    );
                    notifyStmt.setInt(1, followerId); // who did the action
                    notifyStmt.setInt(2, followingId); // who receives it
                    notifyStmt.setString(3, message);
                    notifyStmt.setString(4, "follow");
                    notifyStmt.executeUpdate();
                    notifyStmt.close();
                }
            }

            res.getWriter().write(isFollowing ? "followed" : "unfollowed");

        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().write("error");
        }
    }
}
