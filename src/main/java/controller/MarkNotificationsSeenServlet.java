package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;

@WebServlet("/MarkNotificationsSeenServlet")
public class MarkNotificationsSeenServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession();
        Integer uid = (Integer) session.getAttribute("user_id");

        res.setContentType("text/plain");

        if (uid == null) {
            res.getWriter().write("unauthorized");
            return;
        }

        String idStr = req.getParameter("notification_id");
        if (idStr == null || idStr.trim().isEmpty()) {
            res.getWriter().write("invalid");
            return;
        }

        int notifId = Integer.parseInt(idStr);

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE notifications SET is_seen = 1 WHERE id = ? AND receiver_id = ?"
            );
            ps.setInt(1, notifId);
            ps.setInt(2, uid);
            int rows = ps.executeUpdate();
            ps.close();

            if (rows > 0) {
                res.getWriter().write("seen");
            } else {
                res.getWriter().write("not_found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().write("error");
        }
    }
}
