#ifndef MSG_PROC_H
#define MSG_PROC_H
#include <memory>
#include <deque>
#include <string>
#include <mutex>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <condition_variable>
#include <cstring>
#include <thread>
class session_message{
public:
    session_message(uint32_t conv, uint32_t len, struct sockaddr addr);
    ~session_message();
    char* get_msg_ptr() { return m_msg_ptr; }
    std::string get_sess_key();
    uint32_t get_conv() {return m_conv;}
    uint32_t get_len() {return m_len;}

    
private:
    char* m_msg_ptr;
    struct sockaddr m_addr;
    uint32_t m_conv;
    uint32_t m_len;
};

class msg_proc {
public:
    msg_proc();
    ~msg_proc();
    void push(std::shared_ptr<session_message> &msg);
    void pop(std::shared_ptr<session_message> msg);
    int wait(std::string &data);
private:
    std::deque<std::shared_ptr<session_message> > m_deque_msgs;
    std::mutex m_mutex;
    std::condition_variable m_cv;
};

#endif