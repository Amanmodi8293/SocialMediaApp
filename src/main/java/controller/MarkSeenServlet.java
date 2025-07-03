package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.DBConnection;

@WebServlet("/MarkSeenServlet")
public class MarkSeenServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
		HttpSession session = req.getSession();
		Integer receiverId = (Integer) session.getAttribute("user_id"); // current user

		String senderParam = req.getParameter("sender_id");
		if (receiverId == null || senderParam == null) {
			res.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			return;
		}

		int senderId = Integer.parseInt(senderParam);

		try (Connection conn = DBConnection.getConnection()) {
			PreparedStatement ps = conn.prepareStatement(
				"UPDATE messages SET is_seen = 1 WHERE sender_id = ? AND receiver_id = ? AND is_seen = 0"
			);
			ps.setInt(1, senderId);
			ps.setInt(2, receiverId);
			ps.executeUpdate();
			ps.close();

			res.setStatus(HttpServletResponse.SC_OK);
		} catch (Exception e) {
			e.printStackTrace();
			res.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
		}
	}
}
