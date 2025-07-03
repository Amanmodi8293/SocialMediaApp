<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer uid = (Integer) session.getAttribute("user_id");
    if (uid != null) {
        response.sendRedirect("home.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to SocialConnect</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(to right, #0d6efd, #6610f2);
            color: white;
            font-family: 'Segoe UI', sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .welcome-box {
            background: rgba(255, 255, 255, 0.1);
            padding: 40px;
            border-radius: 16px;
            text-align: center;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.2);
        }

        .welcome-box h1 {
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 20px;
        }

        .btn-start {
            background-color: white;
            color: #0d6efd;
            font-weight: bold;
            border-radius: 30px;
            padding: 10px 30px;
            font-size: 1.1rem;
            text-transform: uppercase;
        }

        .btn-start:hover {
            background-color: #e9ecef;
            color: #0b5ed7;
        }

        .tagline {
            font-size: 1.2rem;
            font-style: italic;
            margin-bottom: 30px;
        }
    </style>
</head>
<body>

<div class="welcome-box">
    <h1>SocialConnect</h1>
    <p class="tagline">Connect, Share, and Inspire.</p>
    <a href="login.jsp" class="btn btn-start">Get Started</a>
</div>

</body>
</html>
