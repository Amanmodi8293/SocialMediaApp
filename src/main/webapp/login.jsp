<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Login - SocialConnect</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(to right, #0d6efd, #6610f2);
            color: white;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-box {
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 16px;
            width: 100%;
            max-width: 400px;
            box-shadow: 0 0 15px rgba(0,0,0,0.2);
        }

        .login-box h2 {
            margin-bottom: 30px;
            font-weight: bold;
            text-align: center;
        }

        .form-control {
            border-radius: 10px;
        }

        .btn-login {
            background-color: white;
            color: #0d6efd;
            font-weight: bold;
            border-radius: 25px;
            padding: 10px;
        }

        .btn-login:hover {
            background-color: #f0f0f0;
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

<div class="login-box">
    <h2>Login to SocialConnect</h2>

    <% if (error != null) { %>
        <div class="error-box">Invalid email or password. Please try again.</div>
    <% } %>

    <form action="LoginServlet" method="post">
        <div class="mb-3">
            <label class="form-label">Email</label>
            <input type="email" name="email" class="form-control" required placeholder="Enter your email">
        </div>
        <div class="mb-3">
            <label class="form-label">Password</label>
            <input type="password" name="password" class="form-control" required placeholder="Enter your password">
        </div>
        <div class="d-grid mb-3">
            <button type="submit" class="btn btn-login">Login</button>
        </div>
        <div class="text-center">
            Don't have an account? <a href="register.jsp">Register here</a>
        </div>
    </form>
</div>

</body>
</html>
