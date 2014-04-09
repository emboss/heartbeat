# heartbeat

### Testing a remote server
To see whether your server is vulnerable to the TLS Heartbleed attack, simply run

```bash
$ ruby heartbeat-test.rb <server> [<port>]
```

If no port is specified, 443 is assumed as the default.

### Testing client software

The Heartbleed attack affects servers and clients alike. You may run a server
that detects vulnerable clients with

```bash
$ ruby heartbeat-server.rb [<port>]
```

The port is optional, by default the server runs on port 4443.

If you'd like to see if your locally installed OpenSSL is vulnerable, simply
open another shell and run

```bash
$ openssl s_client -connect localhost:443
```

Now watch what the heartbeat server has to say about that client.

Another useful thing you might want to do is check whether your updated version
of OpenSSL is picked up correctly by your favorite programming language. The
file `heartbeat-client.rb` contains a simple example for checking if the
OpenSSL version Ruby is compiled against is vulnerable. This approach should
work for any other language that relies on OpenSSL in a similar way.

You can test all kinds of client software, I guess. Browsers, too!

### Can you please make a web app?

No. It's a memory dump after all and who knows what this might contain. This
bug is severe and there have been reports that it was possible to read
passwords, keys and session ids from affected servers. You couldn't possibly
want to trust me with operating a server where I could see parts of the memory
of your local machine! 

### Disclaimer

Do not use this script to cause harm.

### License

None.

### Further info

See http://heartbleed.com/ for further infos on the attack.
