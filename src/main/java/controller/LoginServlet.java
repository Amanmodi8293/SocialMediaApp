package controller;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        try {
            Connection conn = DBConnection.getConnection();

            PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE email=? AND password=?");
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession session = req.getSession();
                session.setAttribute("user_id", rs.getInt("id"));
                session.setAttribute("user_name", rs.getString("name"));
                res.sendRedirect("home.jsp");
            } else {
                res.getWriter().println("Invalid credentials");
            }

            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
