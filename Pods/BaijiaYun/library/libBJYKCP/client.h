
#ifndef CLIENT_H
#define CLIENT_H
#include "session.h"
#include <string>
#include <functional>

typedef std::function<void(void *, std::string data)> on_message;
typedef std::function<void(void *, int)> on_close;
typedef std::function<void(void *)> on_open;
typedef std::function<void(void *, int)> on_fail;

/* error code
enum CLIENT_CONNECT_FALIED_CODE {
	CLINET_SUCESS = 0,
	CLINET_URL_EMPTY = 400,
	CLINET_OPENCB_NOT_SET = 401,
	CLINET_FAILCB_NOT_SET = 402,
	CLINET_CLOSECB_NOT_SET = 403,
	CLINET_MESSAGECB_NOT_SET = 404,
	CLINET_PROTOCOL_NOT_KCP = 405,
	CLINET_GET_HOST_NAME_ERROR = 406,
	CLINET_ALREADY_CREATE = 407,
	CLINET_SOKCET_CREATE_FAILED = 408,
	CLINET_CONNECT_SERVER_FAILED = 409,
	CLINET_SESSION_CREATE_FAILED = 410,
	CLINET_SESSION_NODELAY_FAILED = 411,
};

enum CLIENT_SEND_FALIED_CODE {
	CLINET_CONNECTION_NOT_READY = 412,
	CLINET_SESSION_NOT_OPEN = 413,
	CLINET_SESSION_NULL = 414,
};

enum CLIENT_CLOSE_CODE {
	CLINET_CLOSE_NORMAL = 0,
	CLINET_CONNECTION_TIMEOUT = 416,
};
*/
class kcp_session;
class kcp_client {
public:
    /**
     * @note            设置kcp内部日志路径，全局唯一存在
     * @attention       整个进程开始时设置
     * @param log_path  日志路径
     * @example         kcp_client::set_log_path("/opt/kcp/");
     */
    static void set_log_path(std::string log_path);
    /**
     * @note            释放日志实例
     * @attention       整个进程结束时调用
     * @example         kcp_client::release_log();
     */
    static void release_log();
    /**
     * @note        设置kcp内部日志打印级别
     * @attention
     * @param trace 有以下级别：
     *              TRACE = 0,
     *              DEBUG = 1,
     *              INFO = 2,
     *              WARNING = 3,
     *              ERROR = 4,
     *              FATAL = 5
     */
    static void add_log_trace(int trace);
    /**
     * @note                创建kcp client实例
     * @param encrypt_key   encrypt_key: 长度为16的密钥；
     * @param log_path      使用绝对路径，kcp内部使用
     */
	kcp_client(std::string encrypt_key);
	kcp_client();
	~kcp_client();
    /**
     * @note        连接服务器
     * @param ip    将要连接的服务器IP
     * @param port  将要连接的服务器port
     * @warning     连接失败的话，回调设置的fail_cb函数，有以下失败代码：
     * @details     CLINET_OPENCB_NOT_SET = 401,
     *              CLINET_FAILCB_NOT_SET = 402,
     *              CLINET_CLOSECB_NOT_SET = 403,
     *              CLINET_MESSAGECB_NOT_SET = 404,
     *              CLINET_ALREADY_CREATE = 407
     */
	void connect(std::string ip, uint16_t port);
    /**
     * @note        连接服务器
     * @attention   创建kcp client实例后，设置完回调之后，再使用这个函数连接服务端
     * @param url   kcp://domain:port
     * @warning     连接失败的话，回调fail_cb，同connect(ip,port)
     */
	void connect(std::string url);
	std::shared_ptr<msg_proc> &get_msg_process_instance() {
      return msg_process;
    }
//close delete
	void send_logout();
    void update();
	void open_cb();
	void fail_cb(int);
	void close_cb(int);
    void message_cb();
    /**
     * @note        设置消息处理回调函数，用于处理接收到的数据
     * @param key   值为"message"，否则设置失败
     * @param obj   回调函数的第一个参数
     * @param func  回调函数，函数类型：
     * @details     回调函数类型：
     *              void(void *, std::string &data)
     *              参数1为传入的obj，参数2为接收到的数据
     */
	void set_message_cb(std::string key, void *obj, on_message func);
    /**
     * 设置关闭连接时的回调函数，用于处理与服务端的连接关闭
     * @param key   值为"close"，否则设置失败
     * @param obj   回调函数的第一个参数
     * @param func  回调函数，函数类型：
     *              void(void *, int)
     *              参数1为传入的obj，参数2为关闭代码，代码值如下：
     *              CLINET_CLOSE_NORMAL         = 0,
     *              CLINET_CLOSE_WITH_SERVER    = 415,
     *              CLINET_CONNECTION_TIMEOUT   = 416,
     *              CLINET_CLOSE_WITH_SIGNAL    = 417
     */
	void set_close_cb(std::string key, void *obj, on_close func);
    /**
     * @note        设置连接时失败的回调函数，用于处理connect函数中发生的失败情况
     * @param key   值为"fail"，否则设置失败
     * @param obj   回调函数的第一个参数
     * @param func  回调函数，函数类型：
     *              void(void *, int)
     *              参数1为传入的obj，参数2为关闭代码，代码值如下：
     *              CLINET_OPENCB_NOT_SET = 401,
     *              CLINET_FAILCB_NOT_SET = 402,
     *              CLINET_CLOSECB_NOT_SET = 403,
     *              CLINET_MESSAGECB_NOT_SET = 404,
     *              CLINET_ALREADY_CREATE = 407
     */
	void set_open_failed_cb(std::string key, void *obj, on_fail func);
    /**
     * @note        设置连接成功时回调函数
     * @param key   值为"open"，否则设置失败
     * @param obj   回调函数的第一个参数
     * @param func  回调函数，函数类型：
     *              void(void *)
     */
	void set_open_cb(std::string key, void *obj, on_open func);
    /**
     * @note        发送数据
     * @param data  将要发送的string类型的数据
     * @return      成功返回0(KCP_SUCESS)，失败的返回值：
     *              CLINET_CONNECTION_NOT_READY = 412,
     *              CLINET_SESSION_NOT_OPEN = 413,
     *              CLINET_SESSION_NULL = 414,
     *              KCP_SAND_BUFF_EMPTY = -606,
     *              KCP_NEW_SEGMENT_EMPTY = -607,
     *              KCP_SEND_WND_OVERFLOW = -605
     */
	int send(std::string &data);
    /**
     * @note          设置连接超时时间
     * @attention     只会设置大于10000ms
     * @param timeout 单位ms，默认10000ms
     */
	void set_connection_timeout(int timeout);
	bool get_ready() { return c_ready; }

	int set_dscp(int iptos);

	int close(int code);
	void run();
    //void identity_network(std::vector<std::string> key, std::vector<std::string> value);
    /**
     * 设置上报网络状态时，相关的用户信息，以便区分不同的客户端
     * @param client_info
     * @example std::map<std::string, std::string> map_identy;
     *          map_identy["uid"] = “1234567”;
     *          map_identy["cid"] = kcp_config_inst->get_class_id();
     *          udp_c->set_client_info(map_identy);
     */
    void set_client_info(std::map<std::string, std::string> client_info);
    /**
     * @note        设置rto增长率
     * @attention   值范围在10-100，默认为40
     * @param rto_increase_interval 默认值40，rto增长率40%，kcp client实例化之后或者connect之后设置
     * @return      成功返回0（KCP_RTO_INTERVAL_SUCCESS），有以下失败值：
     *              KCP_RTO_INTERVAL_HIGH = -702，
     *              KCP_RTO_INTERVAL_LOW = -701
     */
    int set_kcp_rto_increase_interval(int rto_increase_interval);
    /**
     * @note        标识当前网络信息，在网络状态发生改变时调用，用于通知server端当前网络信息发生改变
     * @param network_ident 值为当前的网络信息: KCP_4G = 0, KCP_WIFI = 1
     * @return      返回值同send函数
     */
    int notify_network_switch(int network_ident);
private:
    bool check_init();
    bool parse_from_url(const std::string& url, std::string& ip, uint16_t& port);
    bool private_connect();
    bool create_session();
private:
	void* c_open_obj;
	void* c_close_obj;
	void* c_fail_obj;
	void* c_msg_obj;
    struct sockaddr_in c_addr;
	uint32_t c_conv;
	std::shared_ptr<kcp_session> c_sess;
	std::shared_ptr<msg_proc> msg_process;
	std::thread s_threads[3];
	on_message c_message_func;
	on_close c_close_func;
	on_fail c_fail_func;
	on_open c_open_func;
	bool c_ready;
	bool c_open;
	int c_sockfd;
	int c_time_out;
    int c_rto_increase_interval;
	std::string c_encrypt_key;
    std::map<std::string, std::string> c_client_info_map;
};

#endif
