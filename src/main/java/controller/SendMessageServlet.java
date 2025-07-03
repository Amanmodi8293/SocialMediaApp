package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.DBConnection;

@WebServlet("/SendMessageServlet")
public class SendMessageServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
		HttpSession session = req.getSession();
		Integer senderId = (Integer) session.getAttribute("user_id");

		res.setContentType("text/plain");

		try {
			// ✅ Validate receiver_id
			int receiverId;
			try {
				receiverId = Integer.parseInt(req.getParameter("receiver_id"));
				if (receiverId <= 0) {
					res.getWriter().write("invalid");
					return;
				}
			} catch (NumberFormatException e) {
				res.getWriter().write("invalid");
				return;
			}

			String message = req.getParameter("message");
			if (senderId == null || message == null || message.trim().isEmpty()) {
				res.getWriter().write("invalid");
				return;
			}

			try (Connection conn = DBConnection.getConnection()) {
				// ✅ Insert Message
				PreparedStatement ps = conn.prepareStatement(
					"INSERT INTO messages (sender_id, receiver_id, message, created_at, is_seen) VALUES (?, ?, ?, ?, false)"
				);
				ps.setInt(1, senderId);
				ps.setInt(2, receiverId);
				ps.setString(3, message.trim());
				ps.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
				ps.executeUpdate();
				ps.close();

				// ✅ Insert Notification
				String notifMsg = "You received a new message";
				PreparedStatement psNotif = conn.prepareStatement(
					"INSERT INTO notifications (user_id, message, created_at, is_seen) VALUES (?, ?, ?, false)"
				);
				psNotif.setInt(1, receiverId);
				psNotif.setString(2, notifMsg);
				psNotif.setTimestamp(3, new Timestamp(System.currentTimeMillis()));
				psNotif.executeUpdate();
				psNotif.close();

				res.getWriter().write("success");
			}
		} catch (Exception e) {
			e.printStackTrace();
			res.getWriter().write("error");
		}
	}
}
