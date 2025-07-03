package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.DBConnection;

@WebServlet("/FetchMessagesServlet")
public class FetchMessagesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession();
        Integer senderId = (Integer) session.getAttribute("user_id");

        res.setContentType("text/html;charset=UTF-8");
        if (senderId == null) {
            res.getWriter().write("<div class='text-danger'>User not logged in.</div>");
            return;
        }

        try {
            int receiverId = Integer.parseInt(req.getParameter("receiver_id"));

            try (Connection conn = DBConnection.getConnection()) {
                PreparedStatement ps = conn.prepareStatement(
                    "SELECT * FROM messages WHERE " +
                    "(sender_id=? AND receiver_id=?) OR (sender_id=? AND receiver_id=?) " +
                    "ORDER BY created_at ASC"
                );
                ps.setInt(1, senderId);
                ps.setInt(2, receiverId);
                ps.setInt(3, receiverId);
                ps.setInt(4, senderId);

                ResultSet rs = ps.executeQuery();
                StringBuilder sb = new StringBuilder();
                SimpleDateFormat sdf = new SimpleDateFormat("hh:mm a");

                while (rs.next()) {
                    boolean isSent = rs.getInt("sender_id") == senderId;
                    String msg = escapeHtml(rs.getString("message"));
                    String time = sdf.format(rs.getTimestamp("created_at"));
                    boolean seen = rs.getBoolean("is_seen");

                    sb.append("<div class='message ").append(isSent ? "sent" : "received").append("'>")
                      .append("<b>").append(isSent ? "You: " : "Friend: ").append("</b>")
                      .append(msg)
                      .append("<br><small>").append(time);

                    if (isSent) {
                        sb.append(seen ? " ✓✓ Seen" : " ✓ Sent");
                    }

                    sb.append("</small>")
                      .append("</div>");
                }

                res.getWriter().write(sb.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().write("<div class='text-danger'>Error loading messages.</div>");
        }
    }

    // HTML Escape (to prevent XSS)
    private String escapeHtml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;");
    }
}
