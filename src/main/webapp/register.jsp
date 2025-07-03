<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Register - SocialConnect</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(to right, #6610f2, #0d6efd);
            color: white;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .register-box {
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 16px;
            width: 100%;
            max-width: 450px;
            box-shadow: 0 0 15px rgba(0,0,0,0.2);
        }

        .register-box h2 {
            margin-bottom: 25px;
            font-weight: bold;
            text-align: center;
        }

        .form-control {
            border-radius: 10px;
        }

        .btn-register {
            background-color: white;
            color: #0d6efd;
            font-weight: bold;
            border-radius: 25px;
            padding: 10px;
        }

        .btn-register:hover {
            background-color: #e2e6ea;
        }

        .form-label {
            font-weight: 500;
        }

        .error-box {
            background-color: #f8d7da;
            color: #842029;
            padding: 10px 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 0.95rem;
        }

        a {
            color: white;
            text-decoration: underline;
            font-size: 0.9rem;
        }

        a:hover {
            text-decoration: none;
        }
    </style>
</head>
<body>

<div class="register-box">
    <h2>Create Account</h2>

    <% if (error != null) { %>
        <div class="error-box">Email already exists or something went wrong.</div>
    <% } %>

    <form action="${pageContext.request.contextPath}/RegisterServlet" method="post" enctype="multipart/form-data">
        <div class="mb-3">
            <label class="form-label">Full Name</label>
            <input type="text" name="name" class="form-control" required placeholder="Your full name">
        </div>
        <div class="mb-3">
            <label class="form-label">Email</label>
            <input type="email" name="email" class="form-control" required placeholder="you@example.com">
        </div>
        <div class="mb-3">
            <label class="form-label">Password</label>
            <input type="password" name="password" class="form-control" required placeholder="Minimum 6 characters">
        </div>
        <div class="mb-3">
            <label class="form-label">Bio</label>
            <textarea name="bio" class="form-control" placeholder="Tell us something about you..."></textarea>
        </div>
        <div class="mb-3">
            <label class="form-label">Profile Picture</label>
            <input type="file" name="profile_pic" class="form-control" accept="image/*">
        </div>
        <div class="d-grid mb-3">
            <button type="submit" class="btn btn-register">Register</button>
        </div>
        <div class="text-center">
            Already have an account? <a href="login.jsp">Login here</a>
        </div>
    </form>
</div>

</body>
</html>
