$port = 8080
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$page = Join-Path $root 'index.html'
$listener = [System.Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, $port)

try {
  $listener.Start()
  Write-Host "Local page: http://localhost:$port/"
  Write-Host "Keep this window open. Press Ctrl+C to stop."

  while ($true) {
    $client = $listener.AcceptTcpClient()
    try {
      $stream = $client.GetStream()
      $stream.ReadTimeout = 1500
      $reader = [IO.StreamReader]::new($stream, [Text.Encoding]::ASCII, $false, 1024, $true)
      $requestLine = $reader.ReadLine()
      while ($reader.ReadLine()) { }

      $requestPath = ([regex]::Match($requestLine, '^GET\s+([^ ]+)\s+HTTP/').Groups[1].Value -replace '\?.*$', '')
      $file = $null
      $contentType = $null
      switch ($requestPath) {
        '/' { $file = $page; $contentType = 'text/html; charset=utf-8' }
        '/index.html' { $file = $page; $contentType = 'text/html; charset=utf-8' }
        '/images/author.jpg' { $file = Join-Path $root 'images\author.jpg'; $contentType = 'image/jpeg' }
        '/images/Bilibili.webp' { $file = Join-Path $root 'images\Bilibili.webp'; $contentType = 'image/webp' }
        '/images/example.jpg' { $file = Join-Path $root 'images\example.jpg'; $contentType = 'image/jpeg' }
        '/images/Twitch.png' { $file = Join-Path $root 'images\Twitch.png'; $contentType = 'image/png' }
      }
      if ($file -and (Test-Path -LiteralPath $file -PathType Leaf)) {
        $body = [IO.File]::ReadAllBytes($file)
        $headerLines = @('HTTP/1.1 200 OK', ('Content-Type: ' + $contentType), ('Content-Length: ' + $body.Length), 'Connection: close', '', '')
      } else {
        $body = [Text.Encoding]::UTF8.GetBytes('Not found')
        $headerLines = @('HTTP/1.1 404 Not Found', 'Content-Type: text/plain; charset=utf-8', ('Content-Length: ' + $body.Length), 'Connection: close', '', '')
      }
      $header = $headerLines -join [Environment]::NewLine
      $headerBytes = [Text.Encoding]::ASCII.GetBytes($header)
      $stream.Write($headerBytes, 0, $headerBytes.Length)
      $stream.Write($body, 0, $body.Length)
    } catch {
      # A browser preconnect may open a socket without sending a request. Close it and serve the next one.
    } finally {
      $client.Close()
    }
  }
} finally {
  $listener.Stop()
}
