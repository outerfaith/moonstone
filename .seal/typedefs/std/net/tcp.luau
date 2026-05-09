export type TcpStream = {
	read: (self: TcpStream, size: number?) -> buffer?,
	write: (self: TcpStream, data: buffer) -> integer,
	close: (self: TcpStream) -> (),
	read local_ip: string?,
	read local_port: number?,
	read remote_ip: string?,
	read remote_port: number?,
}

export type TcpServer = {
	accept: (self: TcpServer) -> TcpStream?,
	stop: (self: TcpServer) -> (),
	read ip: string,
	read port: number,
}

local tcp = {}

function tcp.serve(port: number, addr: string?): TcpServer
	return tcp.serve(port, addr)
end

return table.freeze(tcp)
