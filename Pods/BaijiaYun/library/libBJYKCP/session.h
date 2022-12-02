
#ifndef SESSION_H
#define SESSION_H

#include <mutex>

#include "ikcp.h"
#include "msg_proc.h"
#include <map>


class kcp_session {
public:
	kcp_session(uint32_t conv, int fd, const struct sockaddr *addr);
	~kcp_session();

	void close(std::string msg);
	void on_recv_udp(const char *buf, int size);
	void process_data();
	void flush();
	void update();

	int init();
	int send_kcp(std::string &data, uint32_t len);
	int send_udp(const char *data, uint32_t len);
	uint32_t get_last_update_time() { return s_time_last_update; }
	ikcpcb* get_kcp() { return s_kcp; }
	std::shared_ptr<msg_proc> get_msg_process() { return s_msg_process; }

private:
	struct sockaddr s_addr;
	int s_sockfd;
	uint32_t s_conv;
	uint32_t s_time_last_update;
	ikcpcb *s_kcp;
	std::mutex s_mutex;
	bool s_ready;
	std::shared_ptr<msg_proc> s_msg_process;
};

#endif
