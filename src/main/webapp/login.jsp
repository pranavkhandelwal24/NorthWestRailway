<%@ page import="javax.servlet.http.HttpSession" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
    <title>NWR Employee Portal</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #0056b3;
            --primary-light: #3a7fc5;
            --primary-dark: #003d7a;
            --secondary: #e63946;
            --light: #f8f9fa;
            --dark: #212529;
            --gray: #6c757d;
            --success: #28a745;
            --transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24);
            --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1), 0 1px 3px rgba(0, 0, 0, 0.08);
            --shadow-lg: 0 10px 20px rgba(0, 0, 0, 0.1), 0 6px 6px rgba(0, 0, 0, 0.1);
            --shadow-xl: 0 15px 25px rgba(0, 0, 0, 0.15), 0 5px 10px rgba(0, 0, 0, 0.05);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', 'Segoe UI', system-ui, -apple-system, sans-serif;
            background: linear-gradient(135deg, #0c2461, #1e3799);
            color: var(--dark);
            line-height: 1.6;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            overflow: hidden;
            position: relative;
        }

        body::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: url('https://akm-img-a-in.tosshub.com/indiatoday/images/story/202408/vande-bharat-214258491-16x9_0.jpeg?VersionId=i9dEnrtGDe_RiH7z5EqjNJbNPfM4CGLH') center/cover no-repeat;
            opacity: 0.15;
            z-index: -1;
        }

        .preloader {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, var(--primary-dark), var(--primary));
            z-index: 9999;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            transition: opacity 0.5s ease, visibility 0.5s ease;
        }

        .preloader-content {
            text-align: center;
            color: white;
            width: 100%;
            max-width: 400px;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .train-animation {
            width: 150px;
            height: 100px;
            margin-bottom: 2rem;
            position: relative;
            display: flex;
            justify-content: center;
        }

        .train-track {
            position: absolute;
            bottom: 30px;
            width: 100%;
            height: 4px;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 2px;
            overflow: hidden;
        }

        .train-track::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: white;
            transform: translateX(-100%);
            animation: trackAnimation 1.5s infinite linear;
        }

        .train-icon {
            position: absolute;
            bottom: 34px;
            left: 50%;
            transform: translateX(-50%);
            font-size: 2.8rem;
            color: white;
            animation: trainAnimation 2s infinite ease-in-out;
        }

        .loading-text {
            font-size: 1.8rem;
            font-weight: 600;
            margin-bottom: 1rem;
            letter-spacing: 1px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .loading-subtext {
            font-size: 1rem;
            opacity: 0.9;
            max-width: 300px;
            margin: 0 auto 2rem;
            transition: opacity 0.3s ease;
        }

        .progress-container {
            width: 80%;
            height: 6px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 3px;
            overflow: hidden;
            margin-bottom: 1rem;
            box-shadow: var(--shadow-sm);
        }

        .progress-bar {
            height: 100%;
            width: 0;
            background: linear-gradient(90deg, rgba(255,255,255,0.8), white);
            border-radius: 3px;
            transition: width 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .progress-bar::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(
                90deg,
                rgba(255, 255, 255, 0) 0%,
                rgba(255, 255, 255, 0.6) 50%,
                rgba(255, 255, 255, 0) 100%
            );
            animation: shimmer 2s infinite;
        }

        @keyframes trainAnimation {
            0%, 100% { transform: translateX(-50%) rotate(0deg); }
            25% { transform: translateX(calc(-50% + 15px)) rotate(2deg); }
            50% { transform: translateX(calc(-50% + 30px)) rotate(0deg); }
            75% { transform: translateX(calc(-50% + 15px)) rotate(-2deg); }
        }

        @keyframes trackAnimation {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }

        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }

        .login-container {
            width: 100%;
            max-width: 420px;
            perspective: 1000px;
        }

        .login-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 2.5rem;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
            position: relative;
            z-index: 2;
            transform-style: preserve-3d;
            animation: float 6s ease-in-out infinite;
            border: 1px solid rgba(255, 255, 255, 0.3);
            backdrop-filter: blur(10px);
            overflow: hidden;
        }

        .login-card::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 60%);
            z-index: -1;
        }

        .login-header {
            margin-bottom: 2rem;
            text-align: center;
            position: relative;
            z-index: 2;
        }

        .logo {
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1.5rem;
        }
        
        .railway-logo {
            height: 50px;
            filter: brightness(1) invert(0);
            opacity: 0.9;
            transition: var(--transition);
        }

        .logo-text {
            font-size: 1.5rem;
            font-weight: 700;
            margin-left: 12px;
            color: var(--primary);
            letter-spacing: 0.5px;
        }

        .login-title {
            font-size: 1.8rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: var(--primary);
            position: relative;
            display: inline-block;
        }

        .login-title::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 50%;
            transform: translateX(-50%);
            width: 50px;
            height: 3px;
            background: linear-gradient(to right, var(--primary), var(--primary-light));
            border-radius: 3px;
        }

        .login-subtitle {
            color: var(--gray);
            font-size: 0.95rem;
            margin-top: 1rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
            width: 100%;
            position: relative;
        }

        .input-label {
            display: block;
            margin-bottom: 0.5rem;
            font-size: 0.95rem;
            font-weight: 500;
            color: var(--dark);
        }

        .input-field {
            width: 100%;
            padding: 1rem 3rem 1rem 3rem; /* Increased left padding */
            border: 1px solid #ddd;
            border-radius: 10px;
            font-size: 1rem;
            transition: var(--transition);
            background-color: white;
            text-align: left; /* Changed to left alignment */
            box-shadow: var(--shadow-sm);
        }

        .input-field::placeholder {
            text-align: left; /* Changed to left alignment */
            color: #aaa;
        }

        .input-field:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(0, 86, 179, 0.1);
            outline: none;
            background-color: white;
        }

        .input-field:invalid:not(:placeholder-shown) {
            border-color: var(--secondary);
        }

        .input-field:invalid:not(:placeholder-shown) + .error-text {
            display: block;
        }

        .input-icon {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--gray);
            font-size: 1.1rem;
            transition: var(--transition);
        }

        .input-field:focus + .input-icon {
            color: var(--primary);
        }

        .password-toggle {
            position: absolute;
            right: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--gray);
            font-size: 1.1rem;
            cursor: pointer;
            z-index: 10;
            transition: var(--transition);
        }

        .password-toggle:hover {
            color: var(--primary);
        }

        .input-wrapper {
            position: relative;
            width: 100%;
        }

        .error-text {
            color: var(--secondary);
            font-size: 0.85rem;
            margin-top: 0.5rem;
            display: none;
            text-align: left; /* Changed to left alignment */
        }

        .remember-forgot {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            width: 100%;
        }

        .remember-me {
            display: flex;
            align-items: center;
        }

        .remember-me input {
            margin-right: 0.5rem;
            cursor: pointer;
            width: 16px;
            height: 16px;
            accent-color: var(--primary);
        }

        .remember-me label {
            cursor: pointer;
            user-select: none;
            font-size: 0.9rem;
        }

        .forgot-password {
            color: var(--primary);
            text-decoration: none;
            font-size: 0.9rem;
            transition: var(--transition);
            position: relative;
        }

        .forgot-password::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            width: 0;
            height: 1px;
            background: var(--primary);
            transition: var(--transition);
        }

        .forgot-password:hover::after {
            width: 100%;
        }

        .login-button {
            width: 100%;
            padding: 1rem;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 1.05rem;
            font-weight: 500;
            cursor: pointer;
            transition: var(--transition);
            position: relative;
            overflow: hidden;
            box-shadow: var(--shadow-md);
            margin-top: 1rem;
        }

        .login-button:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }

        .login-button:active {
            transform: translateY(0);
        }

        .login-button::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(
                90deg,
                transparent,
                rgba(255, 255, 255, 0.2),
                transparent
            );
            transition: 0.5s;
        }

        .login-button:hover::before {
            left: 100%;
        }

        .error-message {
            color: var(--secondary);
            font-size: 0.95rem;
            margin-top: 1rem;
            text-align: center;
            display: none;
            padding: 0.8rem;
            background: rgba(230, 57, 70, 0.1);
            border-radius: 6px;
            border-left: 3px solid var(--secondary);
            animation: fadeIn 0.3s ease;
        }

        .error-message.show {
            display: block;
        }

        .divider {
            display: flex;
            align-items: center;
            margin: 1.8rem 0;
            color: var(--gray);
            font-size: 0.9rem;
            width: 100%;
        }

        .divider::before, .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: #eee;
            margin: 0 1rem;
        }

        .register-link {
            text-align: center;
            margin-top: 1.5rem;
            font-size: 0.95rem;
            width: 100%;
        }

        .register-link a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 500;
            position: relative;
        }

        .register-link a::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            width: 0;
            height: 1px;
            background: var(--primary);
            transition: var(--transition);
        }

        .register-link a:hover::after {
            width: 100%;
        }

        /* Floating animation */
        @keyframes float {
            0% { transform: translateY(0px) rotateY(0deg); }
            50% { transform: translateY(-15px) rotateY(3deg); }
            100% { transform: translateY(0px) rotateY(0deg); }
        }

        /* Background elements */
        .background-train {
            position: absolute;
            font-size: 8rem;
            color: rgba(255, 255, 255, 0.05);
            z-index: 0;
            animation: floatTrain 40s linear infinite;
        }

        .train-1 {
            top: 10%;
            left: -15%;
        }

        .train-2 {
            bottom: 15%;
            right: -10%;
            transform: rotate(180deg);
        }

        @keyframes floatTrain {
            0% { transform: translateX(-100%) rotate(0deg); }
            100% { transform: translateX(100vw) rotate(0deg); }
        }

        .floating-circle {
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.05);
            z-index: 0;
        }

        .circle-1 {
            width: 300px;
            height: 300px;
            top: -150px;
            right: -150px;
        }

        .circle-2 {
            width: 200px;
            height: 200px;
            bottom: -100px;
            left: -100px;
        }

        /* Responsive styles */
        @media (max-width: 480px) {
            .login-card {
                padding: 1.8rem;
            }
            
            .login-title {
                font-size: 1.6rem;
            }
            
            .railway-logo {
                height: 40px;
            }
            
            .logo-text {
                font-size: 1.3rem;
            }
        }

        /* Animations */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
            20%, 40%, 60%, 80% { transform: translateX(5px); }
        }

        .login-card > * {
            animation: fadeInUp 0.5s ease-out forwards;
            opacity: 0;
        }

        .login-card > *:nth-child(1) { animation-delay: 0.1s; }
        .login-card > *:nth-child(2) { animation-delay: 0.2s; }
        .login-card > *:nth-child(3) { animation-delay: 0.3s; }
        .login-card > *:nth-child(4) { animation-delay: 0.4s; }
        .login-card > *:nth-child(5) { animation-delay: 0.5s; }
        .login-card > *:nth-child(6) { animation-delay: 0.6s; }
    </style>
</head>
<body>
    <div class="preloader">
        <div class="preloader-content">
            <div class="train-animation">
                <div class="train-track"></div>
                <i class="fas fa-train train-icon"></i>
            </div>
            <h2 class="loading-text">NORTH WESTERN RAILWAYS</h2>
            <p class="loading-subtext">Initializing secure portal...</p>
            <div class="progress-container">
                <div class="progress-bar"></div>
            </div>
        </div>
    </div>

    <div class="floating-circle circle-1"></div>
    <div class="floating-circle circle-2"></div>
    

    <div class="login-container">
        <div class="login-card">
            <div class="login-header">
                <div class="logo">
                    <img src="https://upload.wikimedia.org/wikipedia/en/thumb/8/83/Indian_Railways.svg/1200px-Indian_Railways.svg.png" 
                         alt="Indian Railways Logo" class="railway-logo">
                    <span class="logo-text">NWR Portal</span>
                </div>
                <h2 class="login-title">Employee Login</h2>
                <p class="login-subtitle">Enter your credentials to access the portal</p>
            </div>
            
            <form id="loginForm" action="login" method="post">
                <div class="form-group">
                    <div class="input-wrapper">
                        <input type="text" id="username" name="username" class="input-field" 
                               placeholder="Enter Username" required>
                        <i class="fas fa-user input-icon"></i>
                    </div>
                    <span class="error-text">Please enter your Username</span>
                </div>
                
                <div class="form-group">
                    <div class="input-wrapper">
                        <input type="password" id="password" name="password" class="input-field" 
                               placeholder="Enter Password" required>
                        <i class="fas fa-lock input-icon"></i>
                        <i class="fas fa-eye password-toggle" id="passwordToggle"></i>
                    </div>
                    <span class="error-text">Please enter your password</span>
                </div>
                
                <div class="remember-forgot">
                    <div class="remember-me">
                        <input type="checkbox" id="remember" name="remember">
                        <label for="remember">Remember me</label>
                    </div>
                    <a href="forgot-password.jsp" class="forgot-password">Forgot password?</a>
                </div>
                
                <button type="submit" class="login-button">Sign In</button>
                <div class="error-message" id="errorMessage"></div>
            </form>
        </div>
    </div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Get form elements
        const loginForm = document.getElementById('loginForm');
        const errorMessage = document.getElementById('errorMessage');
        const usernameInput = document.getElementById('username');
        const passwordInput = document.getElementById('password');
        const rememberCheckbox = document.getElementById('remember');
        const passwordToggle = document.getElementById('passwordToggle');
        const loginButton = document.querySelector('.login-button');
        
        // Password visibility toggle
        passwordToggle.addEventListener('click', function() {
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);
            this.classList.toggle('fa-eye');
            this.classList.toggle('fa-eye-slash');
            
            // Add animation effect
            passwordInput.style.transform = 'scale(1.02)';
            setTimeout(() => {
                passwordInput.style.transform = 'scale(1)';
            }, 200);
        });
        
        // Input focus effects
        const inputs = document.querySelectorAll('.input-field');
        inputs.forEach(input => {
            input.addEventListener('focus', function() {
                this.style.boxShadow = '0 0 0 3px rgba(0, 86, 179, 0.2)';
                this.parentElement.querySelector('.input-icon').style.color = 'var(--primary)';
            });
            
            input.addEventListener('blur', function() {
                this.style.boxShadow = '0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24)';
                this.parentElement.querySelector('.input-icon').style.color = 'var(--gray)';
            });
        });
        
        // Form validation and submission
        loginForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Reset error states
            errorMessage.classList.remove('show');
            usernameInput.classList.remove('invalid');
            passwordInput.classList.remove('invalid');
            
            // Simple validation
            let isValid = true;
            if (!usernameInput.value.trim()) {
                usernameInput.classList.add('invalid');
                isValid = false;
            }
            if (!passwordInput.value) {
                passwordInput.classList.add('invalid');
                isValid = false;
            }
            
            if (!isValid) {
                errorMessage.textContent = "Please fill in all required fields";
                errorMessage.classList.add('show');
                return;
            }
            
            // Show loading state on button
            loginButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Signing in...';
            loginButton.disabled = true;
            
            // Create FormData object from the form
            const formData = new FormData(loginForm);
            
            // Send data to login servlet using fetch API
            fetch('login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams(formData)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    // Successful login - redirect
                    loginButton.innerHTML = '<i class="fas fa-check"></i> Login Successful!';
                    loginButton.style.backgroundColor = 'var(--success)';
                    
                    setTimeout(() => {
                        window.location.href = data.redirectUrl;
                    }, 1000);
                } else {
                    // Show specific error message from server
                    errorMessage.textContent = data.message;
                    errorMessage.classList.add('show');
                    
                    // Shake animation for error
                    loginForm.classList.add('shake');
                    
                    setTimeout(() => {
                        loginForm.classList.remove('shake');
                        
                        // Clear password field
                        passwordInput.value = '';
                        
                        // Focus on the problematic field
                        if (data.errorField === 'username') {
                            usernameInput.focus();
                        } else if (data.errorField === 'password') {
                            passwordInput.focus();
                        }
                    }, 500);
                    
                    // Reset button
                    loginButton.innerHTML = 'Sign In';
                    loginButton.disabled = false;
                }
            })
            .catch(error => {
                errorMessage.textContent = "Error communicating with server. Please try again.";
                errorMessage.classList.add('show');
                console.error('Error:', error);
                
                // Reset button
                loginButton.innerHTML = 'Sign In';
                loginButton.disabled = false;
            });
        });
        
        // Preloader animation
        const preloader = document.querySelector('.preloader');
        const progressBar = document.querySelector('.progress-bar');
        const statusText = document.querySelector('.loading-subtext');
        
        const statusMessages = [
            "Authenticating security protocols...",
            "Connecting to railway database...",
            "Loading employee records...",
            "Finalizing system checks...",
            "Ready to proceed..."
        ];
        
        let progress = 0;
        let currentStatus = 0;
        
        const loadInterval = setInterval(() => {
            progress += Math.random() * 10;
            progress = Math.min(progress, 100);
            progressBar.style.width = progress + '%';
            
            if (progress % 25 < 5) {
                statusText.style.opacity = 0;
                setTimeout(() => {
                    statusText.textContent = statusMessages[currentStatus];
                    statusText.style.opacity = 1;
                    currentStatus = (currentStatus + 1) % statusMessages.length;
                }, 300);
            }
            
            if (progress >= 100) {
                clearInterval(loadInterval);
                setTimeout(() => {
                    preloader.style.opacity = '0';
                    preloader.style.visibility = 'hidden';
                }, 500);
            }
        }, 100);
    });
</script>
</body>
</html>