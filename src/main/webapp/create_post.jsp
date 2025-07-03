<%@ page import="java.sql.*, util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer uid = (Integer) session.getAttribute("user_id");
    if (uid == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Create Post</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f4f6f9;
        }

        .form-container {
            max-width: 500px;
            margin: 50px auto;
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }

        .form-control {
            border-radius: 10px;
        }

        .form-label {
            font-weight: 500;
        }

        .btn-post {
            background-color: #0d6efd;
            color: white;
            border-radius: 20px;
            padding: 10px 20px;
        }

        .btn-post:hover {
            background-color: #0b5ed7;
        }
    </style>
</head>
<body>

<jsp:include page="navbar.jsp" />

<div class="form-container">
    <h3 class="text-center mb-4">Create a New Post</h3>
    <form action="CreatePostServlet" method="post" enctype="multipart/form-data">
        <div class="mb-3">
            <label for="image" class="form-label">Select Image</label>
            <input type="file" class="form-control" id="image" name="image" accept="image/*" required>
        </div>
        <div class="mb-3">
            <label for="content" class="form-label">Caption</label>
            <textarea class="form-control" id="content" name="content" rows="4" placeholder="Write a caption..." required></textarea>
        </div>
        <div class="d-grid">
            <button type="submit" class="btn btn-post">Post</button>
        </div>
    </form>
</div>

</body>
</html>
