<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer uid = (Integer) session.getAttribute("user_id");
    if (uid == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Upload Reel</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(to right, #0d6efd, #6610f2);
            color: white;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        .upload-box {
            background: rgba(255, 255, 255, 0.1);
            padding: 40px;
            border-radius: 20px;
            width: 90%;
            max-width: 500px;
            box-shadow: 0 0 20px rgba(0,0,0,0.2);
        }

        .upload-box h2 {
            text-align: center;
            margin-bottom: 25px;
        }

        .form-control {
            border-radius: 10px;
        }

        .btn-upload {
            background-color: white;
            color: #0d6efd;
            font-weight: bold;
            border-radius: 25px;
            padding: 10px;
        }

        .btn-upload:hover {
            background-color: #f0f0f0;
        }

        .msg-success {
            background-color: #d1e7dd;
            color: #0f5132;
            padding: 10px 15px;
            border-radius: 8px;
            margin-bottom: 15px;
        }

        .msg-error {
            background-color: #f8d7da;
            color: #842029;
            padding: 10px 15px;
            border-radius: 8px;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>

<jsp:include page="navbar.jsp" />

<div class="upload-box">
    <h2>Upload a New Reel</h2>

    <% if ("success".equals(msg)) { %>
        <div class="msg-success">🎉 Reel uploaded successfully!</div>
    <% } else if ("fail".equals(msg)) { %>
        <div class="msg-error">❌ Failed to upload. Try again.</div>
    <% } %>

    <form action="UploadReelServlet" method="post" enctype="multipart/form-data">
        <div class="mb-3">
            <label class="form-label">Caption</label>
            <textarea name="caption" class="form-control" required placeholder="Enter a caption for your reel..."></textarea>
        </div>
        <div class="mb-3">
            <label class="form-label">Select Reel Video</label>
            <input type="file" name="video" class="form-control" required accept="video/*">
        </div>
        <div class="d-grid">
            <button type="submit" class="btn btn-upload">Upload Reel</button>
        </div>
    </form>
</div>

</body>
</html>
