package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.DBConnection;

@WebServlet("/AddReelCommentServlet")
public class AddReelCommentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession();
        Integer userId = (Integer) session.getAttribute("user_id");

        res.setContentType("text/plain");

        try {
            String reelIdStr = req.getParameter("reel_id");
            String comment = req.getParameter("comment");

            if (userId == null || reelIdStr == null || comment == null || comment.trim().isEmpty()) {
                res.getWriter().write("invalid");
                return;
            }

            int reelId = Integer.parseInt(reelIdStr);

            try (Connection conn = DBConnection.getConnection()) {
                // Insert comment
                PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO reel_comments (reel_id, user_id, comment, created_at) VALUES (?, ?, ?, ?)"
                );
                ps.setInt(1, reelId);
                ps.setInt(2, userId);
                ps.setString(3, comment.trim());
                ps.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
                ps.executeUpdate();
                ps.close();

                // 🔔 Notification - Fetch reel owner
                PreparedStatement ownerStmt = conn.prepareStatement("SELECT user_id FROM reels WHERE id = ?");
                ownerStmt.setInt(1, reelId);
                ResultSet ownerRs = ownerStmt.executeQuery();

                if (ownerRs.next()) {
                    int reelOwnerId = ownerRs.getInt("user_id");

                    if (reelOwnerId != userId) {
                        PreparedStatement notifyStmt = conn.prepareStatement(
                            "INSERT INTO notifications (user_id, receiver_id, reel_id, type, message, is_seen, created_at) VALUES (?, ?, ?, ?, ?, 0, NOW())"
                        );
                        notifyStmt.setInt(1, userId); // commenter
                        notifyStmt.setInt(2, reelOwnerId); // receiver
                        notifyStmt.setInt(3, reelId);
                        notifyStmt.setString(4, "reel_comment");
                        notifyStmt.setString(5, "💬 commented on your reel");
                        notifyStmt.executeUpdate();
                        notifyStmt.close();
                    }
                }

                ownerRs.close();
                ownerStmt.close();

                res.getWriter().write("success");
            }

        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().write("error");
        }
    }
}
