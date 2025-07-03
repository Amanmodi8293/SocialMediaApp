package controller;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;

@WebServlet("/FetchUnreadMessageCountServlet")
public class FetchUnreadMessageCountServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession();
        Integer userId = (Integer) session.getAttribute("user_id");

        res.setContentType("text/plain");
        if (userId == null) {
            res.getWriter().write("0");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) FROM messages WHERE receiver_id = ? AND is_seen = FALSE");
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                res.getWriter().write(String.valueOf(rs.getInt(1)));
            } else {
                res.getWriter().write("0");
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().write("0");
        }
    }
}
