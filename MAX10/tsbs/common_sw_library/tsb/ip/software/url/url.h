#ifndef URL_HH_
#define URL_HH_    
#include <string>
struct url {
    url(); // omitted copy, ==, accessors, ...
protected:
    std::string protocol_, host_, path_, query_;
public:
    void parse(const std::string& url_s);
    std::string protocol()   { return protocol_; };
    std::string host()     { return  host_;      };
    std::string path()     { return  path_ ;     };
    std::string query() {return query_;};

};
#endif /* URL_HH_ */
