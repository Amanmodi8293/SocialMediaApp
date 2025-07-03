<%@ page import="java.sql.*, util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer uid = (Integer) session.getAttribute("user_id");
    if (uid == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String name = "", bio = "", profilePic = "default.png";

    try {
        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement("SELECT name, bio, profile_pic FROM users WHERE id = ?");
        ps.setInt(1, uid);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            name = rs.getString("name");
            bio = rs.getString("bio");
            String pp = rs.getString("profile_pic");
            if (pp != null && !pp.trim().isEmpty()) profilePic = pp.trim();
        }
        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Profile</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
        }

        .edit-container {
            max-width: 600px;
            margin: 50px auto;
            background-color: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 0 12px rgba(0, 0, 0, 0.1);
        }

        .form-control, .form-label {
            border-radius: 8px;
        }

        .profile-preview {
            display: block;
            margin: 0 auto 20px;
            width: 120px;
            height: 120px;
            object-fit: cover;
            border-radius: 50%;
            border: 2px solid #007bff;
        }

        .btn-save {
            background-color: #0d6efd;
            color: white;
            border-radius: 20px;
        }

        .btn-save:hover {
            background-color: #0b5ed7;
        }
    </style>
</head>
<body>

<jsp:include page="navbar.jsp" />

<div class="edit-container">
    <h3 class="text-center mb-4">Edit Your Profile</h3>

    <img src="<%=request.getContextPath() + "/" + profilePic%>" class="profile-preview" alt="Profile Picture">

    <form action="UpdateProfileServlet" method="post" enctype="multipart/form-data">
        <div class="mb-3">
            <label class="form-label">Update Name</label>
            <input type="text" name="name" class="form-control" value="<%= name %>" required>
        </div>
        <div class="mb-3">
            <label class="form-label">Update Bio</label>
            <textarea name="bio" class="form-control" rows="4" placeholder="Write something about yourself..."><%= bio %></textarea>
        </div>
        <div class="mb-3">
            <label class="form-label">Change Profile Picture</label>
            <input type="file" name="profile_pic" class="form-control" accept="image/*">
        </div>
        <div class="d-grid">
            <button type="submit" class="btn btn-save">Save Changes</button>
        </div>
    </form>
</div>

</body>
</html>
