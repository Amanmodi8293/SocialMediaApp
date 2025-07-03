package controller;


import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import util.DBConnection; // 🔁 make sure this class exists in your project

@WebServlet("/FetchNotificationsServlet")
public class FetchNotificationsServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("text/plain");
        HttpSession session = req.getSession();
        Integer uid = (Integer) session.getAttribute("user_id");

        if (uid == null) {
            res.getWriter().write("0");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM notifications WHERE receiver_id = ? AND is_seen = 0");
            ps.setInt(1, uid);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                res.getWriter().write(String.valueOf(rs.getInt(1)));
            } else {
                res.getWriter().write("0");
            }
        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().write("0");
        }
    }
}
