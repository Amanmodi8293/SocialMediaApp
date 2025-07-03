<%@ page import="java.sql.*, util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer uid = (Integer) session.getAttribute("user_id");
    if (uid == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int postId = 0;
    String image = "", caption = "";

    try {
        postId = Integer.parseInt(request.getParameter("post_id"));
        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM posts WHERE id=? AND user_id=?");
        ps.setInt(1, postId);
        ps.setInt(2, uid);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            image = rs.getString("image_path");
            caption = rs.getString("content");
        } else {
            out.println("<div class='text-danger'>Unauthorized access or post not found.</div>");
            return;
        }

        rs.close(); ps.close(); conn.close();
    } catch (Exception e) {
        out.println("<div class='text-danger'>Error loading post: " + e.getMessage() + "</div>");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Post</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<jsp:include page="navbar.jsp" />

<div class="container mt-5" style="max-width: 600px;">
    <h3 class="mb-4 text-center">Edit Post</h3>
    <form action="EditPostServlet" method="post" enctype="multipart/form-data">
        <input type="hidden" name="post_id" value="<%= postId %>">

        <div class="mb-3">
            <label class="form-label">Current Image</label><br>
            <img src="<%=request.getContextPath() + "/" + image%>" style="width: 100%; max-height: 300px; object-fit: contain;">
        </div>

        <div class="mb-3">
            <label class="form-label">Change Image (optional)</label>
            <input type="file" name="image" class="form-control">
        </div>

        <div class="mb-3">
            <label class="form-label">Caption</label>
            <textarea name="caption" class="form-control" rows="3" required><%= caption %></textarea>
        </div>

        <button type="submit" class="btn btn-primary">Update Post</button>
        <a href="profile.jsp" class="btn btn-secondary">Cancel</a>
    </form>
</div>
</body>
</html>
