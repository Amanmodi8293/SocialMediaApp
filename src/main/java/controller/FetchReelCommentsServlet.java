// ✅ FetchReelCommentsServlet.java
package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.DBConnection;

@WebServlet("/FetchReelCommentsServlet")
public class FetchReelCommentsServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        int reelId = Integer.parseInt(req.getParameter("reel_id"));
        res.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = res.getWriter();
             Connection conn = DBConnection.getConnection();
        	    PreparedStatement ps = conn.prepareStatement(
                        "SELECT c.comment, u.name, u.profile_pic, c.created_at " +
                        "FROM reel_comments c JOIN users u ON c.user_id = u.id " +
                        "WHERE c.reel_id = ? ORDER BY c.created_at DESC"
                    );) {

            ps.setInt(1, reelId);
            ResultSet rs = ps.executeQuery();
           
            while (rs.next()) {
                String name = rs.getString("name");
                String comment = rs.getString("comment");
                String profile = rs.getString("profile_pic");
                if (profile == null || profile.trim().isEmpty()) profile = "default.png";
                String time = rs.getString("created_at");

                out.println("<div class='mb-2'>" +
                        "<img src='" + req.getContextPath() + "/" + profile + "' width='30' height='30' class='rounded-circle me-2'>" +
                        "<strong>" + name + ":</strong> " +
                        "<span>" + comment + "</span><br>" +
                        "<small class='text-muted'>" + time + "</small>" +
                    "</div>");
            }
            rs.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

































