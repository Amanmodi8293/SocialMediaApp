package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;

@WebServlet("/ToggleReelLikeServlet")
public class ToggleReelLikeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession();
        Integer userId = (Integer) session.getAttribute("user_id");

        if (userId == null) {
            res.getWriter().write("unauthenticated");
            return;
        }

        int reelId = Integer.parseInt(req.getParameter("reel_id"));

        try (Connection conn = DBConnection.getConnection()) {
            // Check if already liked
            PreparedStatement checkStmt = conn.prepareStatement("SELECT * FROM reel_likes WHERE reel_id=? AND user_id=?");
            checkStmt.setInt(1, reelId);
            checkStmt.setInt(2, userId);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                // Already liked → Remove like
                PreparedStatement deleteStmt = conn.prepareStatement("DELETE FROM reel_likes WHERE reel_id=? AND user_id=?");
                deleteStmt.setInt(1, reelId);
                deleteStmt.setInt(2, userId);
                deleteStmt.executeUpdate();
                res.getWriter().write("unliked");
                deleteStmt.close();
            } else {
                // Not liked → Add like
                PreparedStatement insertStmt = conn.prepareStatement("INSERT INTO reel_likes (reel_id, user_id) VALUES (?, ?)");
                insertStmt.setInt(1, reelId);
                insertStmt.setInt(2, userId);
                insertStmt.executeUpdate();
                res.getWriter().write("liked");
                insertStmt.close();

                // 🔔 Notification: Get reel owner
                PreparedStatement ownerStmt = conn.prepareStatement("SELECT user_id FROM reels WHERE id = ?");
                ownerStmt.setInt(1, reelId);
                ResultSet ownerRs = ownerStmt.executeQuery();

                if (ownerRs.next()) {
                    int reelOwnerId = ownerRs.getInt("user_id");

                    if (reelOwnerId != userId) {
                        PreparedStatement notifyStmt = conn.prepareStatement(
                            "INSERT INTO notifications (user_id, receiver_id, reel_id, type, message, is_seen, created_at) VALUES (?, ?, ?, ?, ?, 0, NOW())"
                        );
                        notifyStmt.setInt(1, userId); // liker
                        notifyStmt.setInt(2, reelOwnerId); // receiver
                        notifyStmt.setInt(3, reelId);
                        notifyStmt.setString(4, "reel_like");
                        notifyStmt.setString(5, "❤️ liked your reel");
                        notifyStmt.executeUpdate();
                        notifyStmt.close();
                    }
                }

                ownerRs.close();
                ownerStmt.close();
            }

            rs.close();
            checkStmt.close();

        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().write("error");
        }
    }
}
