<%@ page import="java.sql.*, util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer uid = (Integer) session.getAttribute("user_id");
    if (uid == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int receiverId = 0;
    String receiverName = "Unknown";
    String receiverPic = "default.png";

    try {
        receiverId = Integer.parseInt(request.getParameter("receiver_id"));
        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement("SELECT name, profile_pic FROM users WHERE id = ?");
        ps.setInt(1, receiverId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            receiverName = rs.getString("name");
            String pic = rs.getString("profile_pic");
            if (pic != null && !pic.trim().isEmpty()) receiverPic = pic;
        }
        rs.close(); ps.close(); conn.close();
    } catch (Exception e) {
        response.sendRedirect("home.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Chat with <%= receiverName %></title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        html, body {
            height: 100%;
            overflow: auto;
            scrollbar-width: none;
            -ms-overflow-style: none;
        }
        html::-webkit-scrollbar, body::-webkit-scrollbar {
            display: none;
        }

        * {
            user-select: none;
        }

        .chat-container {
            max-width: 800px;
            margin: 0 auto;
            height: 90vh;
            display: flex;
            flex-direction: column;
            background: #fff;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }

        .chat-header {
            background: linear-gradient(to right, #833ab4, #fd1d1d, #fcb045);
            color: white;
            padding: 15px;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .chat-header img {
            width: 48px;
            height: 48px;
            object-fit: cover;
            border-radius: 50%;
            border: 2px solid white;
        }

        .chat-messages {
            flex: 1;
            overflow-y: auto;
            background: #f0f0f0;
            padding: 20px;
            display: flex;
            flex-direction: column;
            gap: 12px;
            scrollbar-width: none;
        }

        .chat-messages::-webkit-scrollbar {
            display: none;
        }

        .message-bubble {
            max-width: 90%;
            word-wrap: break-word;
            overflow-wrap: break-word;
            white-space: pre-wrap;
            padding: 12px 16px;
            border-radius: 18px;
            font-size: 15px;
            line-height: 1.4;
            box-shadow: 0 1px 2px rgba(0,0,0,0.1);
            display: inline-block;
        }

        .sent {
            background: #4fd9e2a3;
            align-self: flex-end;
            border-bottom-right-radius: 0;
            text-align: left;
            max-width: 90%;
            overflow-wrap: break-word;
            padding: 10px;
            border-radius: 20px;
        }

        .received {
            background: #f70b0b9c;
            align-self: flex-start;
            border-bottom-left-radius: 0;
            text-align: left;
            max-width: 90%;
            overflow-wrap: break-word;
            padding: 10px;
            border-radius: 20px;
        }

        .timestamp {
            font-size: 11px;
            color: #888;
            margin-top: 4px;
            text-align: right;
        }

        .seen-status {
            font-size: 10px;
            color: #999;
            margin-left: 5px;
        }

        .chat-input {
            display: flex;
            padding: 15px;
            background: #f5f5f5;
            border-top: 1px solid #ddd;
        }

        .chat-input input {
            flex: 1;
            padding: 10px 16px;
            border-radius: 25px;
            border: 1px solid #ccc;
            outline: none;
            font-size: 14px;
            margin-right: 10px;
        }

        .chat-input button {
            padding: 10px 20px;
            border-radius: 25px;
            border: none;
            background: #007bff;
            color: white;
            font-weight: bold;
            min-width: 80px;
        }

        .chat-input button:hover {
            background: #0056b3;
        }

        @media (max-width: 600px) {
            .chat-container {
                margin: 0;
                border-radius: 0;
                height: 92vh;
            }

            .message-bubble {
                font-size: 13px;
                padding: 10px 14px;
            }

            .chat-input input {
                font-size: 13px;
            }

            .chat-input button {
                font-size: 13px;
                min-width: 60px;
            }
        }
    </style>
</head>
<body>

<jsp:include page="navbar.jsp" />

<div class="chat-container">
    <!-- Chat Header -->
    <div class="chat-header">
        <img src="<%=request.getContextPath() + "/" + receiverPic%>" alt="User" />
        <h5><%= receiverName %></h5>
    </div>

    <!-- Messages -->
    <div id="chatMessages" class="chat-messages">
        <!-- AJAX messages here -->
    </div>

    <!-- Input -->
    <div class="chat-input">
        <input type="text" id="messageInput" placeholder="Type a message...">
        <button onclick="sendMessage()">Send</button>
    </div>
</div>

<script>
    const receiverId = <%= receiverId %>;
    const messageInput = document.getElementById("messageInput");
    const chatMessages = document.getElementById("chatMessages");

    function fetchMessages() {
        fetch("FetchMessagesServlet?receiver_id=" + receiverId)
            .then(res => res.text())
            .then(data => {
                chatMessages.innerHTML = data;
                chatMessages.scrollTop = chatMessages.scrollHeight;
            });
    }

    function sendMessage() {
        const msg = messageInput.value.trim();
        if (msg === "") return;

        fetch("SendMessageServlet", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "receiver_id=" + receiverId + "&message=" + encodeURIComponent(msg)
        }).then(() => {
            messageInput.value = "";
            fetchMessages();
        });
    }

    // Seen Marker
    document.addEventListener("DOMContentLoaded", function () {
        const urlParams = new URLSearchParams(window.location.search);
        const senderId = urlParams.get("receiver_id");

        fetch("MarkSeenServlet", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "sender_id=" + senderId
        }).then(res => {
            if (res.ok) {
                console.log("✅ Messages marked as seen.");
            } else {
                console.log("❌ Failed to mark seen.");
            }
        });
    });

    // Auto fetch
    setInterval(fetchMessages, 3000);
    window.onload = fetchMessages;
</script>

</body>
</html>
