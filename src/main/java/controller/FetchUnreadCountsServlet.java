package controller;

import org.json.JSONObject;
import util.DBConnection;
import java.io.IOException;
import java.sql.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;


@WebServlet("/FetchUnreadCountsServlet")
public class FetchUnreadCountsServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("user_id");

        JSONObject result = new JSONObject();

        if (userId == null) {
            response.setStatus(401);
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT sender_id, COUNT(*) AS unseen_count FROM messages " +
                "WHERE receiver_id = ? AND is_seen = 0 GROUP BY sender_id"
            );
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                int senderId = rs.getInt("sender_id");
                int count = rs.getInt("unseen_count");
                result.put(String.valueOf(senderId), count);
            }

            rs.close();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.getWriter().write(result.toString());
    }
}
