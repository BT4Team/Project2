<h1 align="center">Dex2c – APK Protection by BT4 Team</h1>

<p align="center">
  <b>Dex2c</b> is an advanced APK protection and obfuscation solution developed by the <b>BT4 Team</b>.<br>
  It converts APK DEX code into protected native libraries, making reverse engineering and tampering significantly harder.
</p>

<p align="center">
  <a href="https://bt4team.com">🌐 Official Website</a> &nbsp;|&nbsp;
  <b>© 2023–2025 BT4 Team</b>
</p>

<hr>

<h2>📦 Features</h2>

<ul>
  <li>Convert DEX code to native C code</li>
  <li>Protect APKs from decompilation</li>
  <li>Support for custom native loaders</li>
  <li>Integration-ready with existing Android projects</li>
  <li>Lightweight and optimized for performance</li>
</ul>

<hr>

<h2>📲 Requirements</h2>

<ul>
  <li><b>Termux</b> (latest version)</li>
  <li><b>Android 7.0+</b></li>
  <li>Internet access for downloading dependencies</li>
  <li>Storage permission for file access</li>
</ul>

<hr>

<h2>⚙️ Installation Guide</h2>

<h3>✅ 1. Install Termux</h3>
<p>Download and install the latest version of Termux from F-Droid or Google Play.</p>

<h3>✅ 2. Install Dex2c</h3>

```bash
pkg install wget -y
wget -O dex2c.sh https://raw.githubusercontent.com/BT4Team/BT4-Dex2c/main/dex2c.sh
chmod +x dex2c.sh
./dex2c.sh
```