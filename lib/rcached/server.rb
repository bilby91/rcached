class RCached::Server

  attr_reader :host, :port, :tcp_server, :cache

  def initialize(host, port)
    @host = host
    @port = port
    @tcp_server = TCPServer.new @host, @port
    @cache = RCached::Cache.new
  end

  # Start listening for client request.
  def start
    loop do
      begin
        socket = tcp_server.accept

        handle_request(socket)
      ensure
        socket.close
      end
    end
  end

  # Handle client request. Write cache response into socket
  def handle_request(socket)
    message = parse_message(socket)

    response = cache.run(message[:command], *message[:arguments])

    if message[:noreply].nil? || message[:noreply] == false
      socket.puts response
    end
  end

  # Supported commands and formats are
  #
  # [set | add | replace] key flags expiration length <noreply>
  # [append | prepend] key length <noreply>
  # cas key flags expiration length casunique <noreply>
  # [get | gets] key1 <key2 ... keyn>
  def parse_message(socket)
    command_key, options_unsplitted = socket.gets.split(' ', 2)
    arguments = options_unsplitted.split(' ')
    noreply = false

    if ['set', 'add', 'replace', 'cas'].include?(command_key)
      _, _, _, length, noreply = arguments

      noreply = true if noreply == 'noreply'

      arguments << socket.recv(length.to_i)
    elsif ['append', 'prepend'].include?(command_key)
      _, length, noreply =  arguments

      noreply = true if noreply == 'noreply'

      arguments << socket.recv(length.to_i)
    end

    { command: command_key, arguments: arguments, noreply: noreply }
  end

end
