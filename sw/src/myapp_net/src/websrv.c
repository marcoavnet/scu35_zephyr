#include <zephyr/kernel.h>
#include <zephyr/net/socket.h>
#include <zephyr/sys/printk.h>
#include <string.h>
#include <errno.h>

#define HTTP_PORT 80
#define RECV_BUF_SIZE 512

static const char http_response[] =
	"HTTP/1.1 200 OK\r\n"
	"Content-Type: text/html\r\n"
	"Connection: close\r\n"
	"\r\n"
	"<!DOCTYPE html>"
	"<html>"
	"<head><title>Zephyr Webserver</title></head>"
	"<body>"
	"<h1>Hello from Zephyr!</h1>"
	"<p>AXI Ethernet Lite is working.</p>"
	"</body>"
	"</html>";

void websrv_thread(void *arg1, void *arg2, void *arg3)
{
	int server_fd;
	struct sockaddr_in addr;
	char recv_buf[RECV_BUF_SIZE];

	printk("Starting Zephyr webserver...\n");

	server_fd = zsock_socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (server_fd < 0) {
		printk("socket() failed: %d\n", errno);
		return;
	}

	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(HTTP_PORT);
	addr.sin_addr.s_addr = htonl(INADDR_ANY);

	if (zsock_bind(server_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
		printk("bind() failed: %d\n", errno);
		zsock_close(server_fd);
		return;
	}

	if (zsock_listen(server_fd, 1) < 0) {
		printk("listen() failed: %d\n", errno);
		zsock_close(server_fd);
		return;
	}

	printk("Webserver listening on http://192.168.0.50/\n");

	while (1) {
		struct sockaddr_in client_addr;
		socklen_t client_len = sizeof(client_addr);

		int client_fd = zsock_accept(server_fd,
				       (struct sockaddr *)&client_addr,
				       &client_len);

		if (client_fd < 0) {
			printk("accept() failed: %d\n", errno);
			continue;
		}

		int len = zsock_recv(client_fd, recv_buf, sizeof(recv_buf) - 1, 0);
		if (len > 0) {
			recv_buf[len] = '\0';
			printk("HTTP request:\n%s\n", recv_buf);

			zsock_send(client_fd, http_response,
			     strlen(http_response), 0);
		}

		zsock_close(client_fd);
	}
}