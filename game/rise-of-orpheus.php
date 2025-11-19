<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rise of Orpheus - Social Casino</title>
    <link rel="icon" type="image/png" href="images/logo.webp">
    <link rel="stylesheet" href="css/style30f4.css?v=4">
</head>
<body>

<!-- Age Verification Popup -->
<div id="age-verification-popup" class="age-popup-overlay">
    <div class="age-popup-container">
        <div class="age-popup-content">
            <!-- Popup Header -->
            <div class="age-popup-header">
                <div class="age-icon">🔞</div>
                <h2>Age Verification</h2>
            </div>
            
            <!-- Popup Body -->
            <div class="age-popup-body">
                <p class="age-message">To continue, you must be 18 years or older. Please confirm your age to access our games and content.</p>
                <p class="age-subtitle">Adult content ahead — strictly for users aged 18 and above.</p>
                
                                <!-- Verification Form -->
                <form class="age-verification-form" onsubmit="return false;">
                    <div class="age-buttons">
                        <button type="button" name="age_verification" value="confirm" class="age-btn age-btn-primary">
                            I am 18 or older                        </button>
                        <button type="button" name="age_verification" value="deny" class="age-btn age-btn-secondary">
                            I am under 18                        </button>
                    </div>
                </form>
                            </div>
            
            <!-- Popup Footer -->
            <div class="age-popup-footer">
                <p class="age-disclaimer">
                     All games are for entertainment purposes only. No real money is involved. Enjoy responsibly and have fun!                </p>
            </div>
        </div>
    </div>
</div>

<!-- Age Verification Styles -->
<style>
.age-popup-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.95);
    backdrop-filter: blur(10px);
    z-index: 10000;
    display: flex;
    align-items: center;
    justify-content: center;
    animation: fadeIn 0.5s ease;
}

.age-popup-container {
    background: linear-gradient(135deg, #4c1d95 0%, #ec4899 50%, #f97316 100%);
    border-radius: 20px;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
    max-width: 500px;
    width: 90%;
    animation: slideIn 0.5s ease;
}

.age-popup-content {
    padding: 2rem;
    text-align: center;
    color: white;
}


.age-popup-header {
    margin-bottom: 2rem;
}

.age-icon {
    font-size: 4rem;
    margin-bottom: 1rem;
    animation: pulse 2s infinite;
}

.age-popup-header h2 {
    font-size: 2rem;
    margin: 0;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
}

.age-popup-body {
    margin-bottom: 2rem;
}

.age-message {
    font-size: 1.2rem;
    margin-bottom: 1rem;
    font-weight: bold;
}

.age-subtitle {
    font-size: 1rem;
    margin-bottom: 2rem;
    opacity: 0.9;
}

.age-verification-form {
    margin: 0;
}

.age-buttons {
    display: flex;
    gap: 1rem;
    justify-content: center;
    flex-wrap: wrap;
}

.age-btn {
    padding: 15px 30px;
    border: none;
    border-radius: 25px;
    font-size: 1.1rem;
    font-weight: bold;
    cursor: pointer;
    transition: all 0.3s ease;
    text-transform: uppercase;
    letter-spacing: 1px;
    min-width: 200px;
}

.age-btn-primary {
    background: linear-gradient(45deg, #f97316, #fb923c);
    color: #333;
    box-shadow: 0 6px 20px rgba(249, 115, 22, 0.45);
}

.age-btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(249, 115, 22, 0.6);
}

.age-btn-secondary {
    background: rgba(255, 255, 255, 0.2);
    color: white;
    border: 2px solid rgba(255, 255, 255, 0.3);
}

.age-btn-secondary:hover {
    background: rgba(255, 255, 255, 0.3);
    transform: translateY(-2px);
}

.age-denial-message {
    background: rgba(236, 72, 153, 0.2);
    border: 2px solid #ec4899;
    border-radius: 15px;
    padding: 2rem;
    margin: 1rem 0;
}

.age-denial-message h3 {
    color: #ec4899;
    font-size: 1.5rem;
    margin-bottom: 1rem;
}

.age-denial-message p {
    font-size: 1.1rem;
    margin-bottom: 1.5rem;
}

.age-denial-actions {
    text-align: center;
}

.age-popup-footer {
    border-top: 1px solid rgba(255, 255, 255, 0.2);
    padding-top: 1rem;
}

.age-disclaimer {
    font-size: 0.9rem;
    opacity: 0.8;
    margin: 0;
    line-height: 1.4;
}

/* Animations */
@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

@keyframes slideIn {
    from { 
        opacity: 0;
        transform: translateY(-50px) scale(0.9);
    }
    to { 
        opacity: 1;
        transform: translateY(0) scale(1);
    }
}

@keyframes pulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.1); }
}

/* Responsive Design */
@media (max-width: 768px) {
    .age-popup-container {
        width: 95%;
        margin: 1rem;
    }
    
    .age-popup-content {
        padding: 1.5rem;
    }
    
    .age-buttons {
        flex-direction: column;
        align-items: center;
    }
    
    .age-btn {
        width: 100%;
        max-width: 300px;
    }
    
    .age-popup-header h2 {
        font-size: 1.5rem;
    }
    
    .age-icon {
        font-size: 3rem;
    }
}
</style>

<!-- Age Verification JavaScript -->
<script>
// Prevent any interaction with the page until age is verified
document.addEventListener('DOMContentLoaded', function() {
    const popup = document.getElementById('age-verification-popup');
    if (popup) {
        // Disable all page interactions
        document.body.style.overflow = 'hidden';
        document.body.style.pointerEvents = 'none';
        
        // Re-enable interactions only for the popup
        popup.style.pointerEvents = 'auto';
        
        // Prevent right-click, F12, etc.
        document.addEventListener('contextmenu', function(e) {
            e.preventDefault();
            return false;
        });
        
        document.addEventListener('keydown', function(e) {
            // Block F12, Ctrl+Shift+I, Ctrl+U, etc.
            if (e.key === 'F12' || 
                (e.ctrlKey && e.shiftKey && e.key === 'I') ||
                (e.ctrlKey && e.key === 'u')) {
                e.preventDefault();
                return false;
            }
        });
    }
});
</script>
<!-- Header -->
<header class="header">
    <div class="container">
        <div class="logo">
            <a href="index.php">
                <img src="images/logo.webp" alt="Social Casino Logo" class="logo-image">
                <span class="site-name">sweetswoop</span>
            </a>
        </div>
        <nav class="nav">
            <ul>
                <li><a href="index.php#how-it-works">How to Play</a></li>
                <li><a href="index.php#games">Play Now</a></li>
                <li><a href="index.php#leaderboard">Leaderboard</a></li>
                <li>
                    <a href="about.php" >About Us</a>
                </li>
                <li>
                    <a href="contact.php" >Support</a>
                </li>
            </ul>
        </nav>
    </div>
</header>

<!-- Main Content -->
<main class="main">
    <div class="container">

     

            <!-- Game Container -->
            <section class="game-container">
                <div class="container">
                    <div class="game-wrapper">
                        <div class="game-iframe-container">
                            <iframe 
                                src="https://released.playngonetwork.com/casino/ContainerLauncher?pid=2&amp;gid=riseoforpheus&amp;lang=en_GB&amp;practice=1&amp;channel=desktop&amp;demo=2&amp;refresh=1758626839905" 
                                width="100%" 
                                height="600" 
                                frameborder="0" 
                                allowfullscreen
                                title="Rise of Orpheus Game">
                            </iframe>
                        </div>
                        
                        <div class="game-info">
                            <h3>Rise of Orpheus</h3>
                            <p>Experience the thrill of Rise of Orpheus with our free-to-play version!</p>
                            
                            <div class="game-controls">
                                <button class="play-btn" onclick="location.reload()">Restart Game</button>
                                <button class="cta-btn secondary" onclick="window.location.href='index.php'">Back to Games</button>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Related Games Section -->
            <section class="related-games-section">
                <div class="container">
                    <h3>More Games</h3>
                    <div class="games-grid">
                                                <div class="game-card" data-game="a2711edd47f8e4c6e72f29a96b4f878c">
                            <img src="games-image/tombofgold2_Panel_Small.webp" 
                                 alt="Tomb of Gold II" 
                                 class="game-icon">
                            <h4>Tomb of Gold II</h4>
                            <a href="tomb-of-gold-ii.php?title=Tomb+of+Gold+II" class="play-btn">Play Now</a>
                        </div>
                                                <div class="game-card" data-game="c13c39ab342c1ea3e72c2f0c6251ae21">
                            <img src="games-image/leprechaundiamonddig_Panel_Small.webp" 
                                 alt="Leprechaun&#039;s Diamond Dig" 
                                 class="game-icon">
                            <h4>Leprechaun&#039;s Diamond Dig</h4>
                            <a href="leprechauns-diamond-dig.php?title=Leprechaun%27s+Diamond+Dig" class="play-btn">Play Now</a>
                        </div>
                                                <div class="game-card" data-game="1c39064189e1cd1eb3ebc9c1d31b569a">
                            <img src="games-image/lionsagaodyssey_Panel_Small.webp" 
                                 alt="Lion Saga Odyssey" 
                                 class="game-icon">
                            <h4>Lion Saga Odyssey</h4>
                            <a href="lion-saga-odyssey.php?title=Lion+Saga+Odyssey" class="play-btn">Play Now</a>
                        </div>
                                            </div>
                </div>
            </section>

<style>
.game-container {
    padding: 2rem 0;
}

.game-wrapper {
    background: var(--glass-bg-light);
    border-radius: 20px;
    padding: 2rem;
    box-shadow: var(--shadow-heavy);
}

.game-iframe-container {
    margin-bottom: 2rem;
    border-radius: 15px;
    overflow: hidden;
    box-shadow: var(--shadow-medium);
}

.game-info {
    text-align: center;
    margin-bottom: 2rem;
}

.game-info h3 {
    color: var(--text-dark);
    font-size: 2rem;
    margin-bottom: 1rem;
}

.game-info p {
    color: var(--text-gray);
    font-size: 1.1rem;
    margin-bottom: 2rem;
}

.game-controls {
    display: flex;
    gap: 1rem;
    justify-content: center;
    flex-wrap: wrap;
}

.related-games-section {
    background: var(--glass-bg);
    border-radius: 20px;
    padding: 3rem 2rem;
    margin: 3rem 0;
    text-align: center;
}

.related-games-section h3 {
    color: var(--text-white);
    font-size: 2.5rem;
    margin-bottom: 2rem;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
}

@media (max-width: 768px) {
    .game-iframe-container iframe {
        height: 400px;
    }
    
    .game-controls {
        flex-direction: column;
        align-items: center;
    }
    
    .game-controls .play-btn,
    .game-controls .cta-btn {
        width: 100%;
        max-width: 300px;
    }
}
</style>

</div>
</main>

<!-- Footer -->
<footer class="footer">
    <div class="container">
        <!-- Disclaimer -->
        <div class="disclaimer">
            <p>For adults 18+. All games are virtual and for entertainment purposes only. sweetswoop does not offer real-money gambling.</p>
        </div>

        <div class="footer-main-content">
            <div class="footer-links">
                <div class="footer-section">
                    <h4>Quick Links</h4>
                    <ul>
                        <li><a href="about.php">About Us</a></li>
                        <li><a href="contact.php">Support</a></li>
                        <li><a href="privacy.php">Privacy Policy</a></li>
                        <li><a href="terms.php">Terms of Service</a></li>
                    </ul>
                </div>
            </div>

            <!-- Footer Icons with Links -->
            <div class="footer-icons-with-links">
                <a href="https://gamblingtherapy.org/" target="_blank" rel="noopener">
                    <img src="images/gambling-therapy.png" alt="Gambling Therapy" class="footer-link-image">
                </a>

                <a href="https://www.gamcare.org.uk/" target="_blank" rel="noopener">
                    <img src="images/gamcare.png" alt="GamCare" class="footer-link-image">
                </a>

                <a href="https://www.gambleaware.org/" target="_blank" rel="noopener">
                    <img src="images/gambleaware.png" alt="GambleAware" class="footer-link-image">
                </a>
            </div>
        </div>

        <!-- Footer Icons without Links -->
        <div class="footer-icons-no-links">
            <img src="images/footer-icons.png" alt="Footer Icons" class="footer-icons-image">
        </div>

        <!-- Copyright -->
        <div class="copyright">
         <p>2025 sweetswoop.site                - © All rights reserved. Play responsibly. Entertainment only.</p>
        </div>
    </div>
</footer>

<!-- Cookie Policy Popup -->
<div id="cookie-popup" class="cookie-popup">
    <div class="cookie-content">
        <div class="cookie-header">
            <h4>Cookies & Your Experience</h4>
        </div>
        <div class="cookie-body">
            <p>We use cookies to enhance your experience, provide personalized content, and analyze usage. Accept all for full functionality.</p>
        </div>
        <div class="cookie-actions">
            <button id="cookie-accept-all"
                    class="cookie-btn cookie-btn-primary">Accept All</button>
            <button id="cookie-accept-necessary"
                    class="cookie-btn cookie-btn-secondary">Necessary Only</button>
        </div>
    </div>
</div>

<script src="js/main30f4.js?v=4"></script>
<script src="js/cookie-popup30f4.js?v=3"></script>
</body>

</html>