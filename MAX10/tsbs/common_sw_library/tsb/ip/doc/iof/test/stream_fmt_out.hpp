#ifndef STREAM_FMT_OUT_HPP_
#define STREAM_FMT_OUT_HPP_

namespace iof 
{
inline std::ostream& 
operator<<(std::ostream& out, const stream_fmt& fmt)
{
    out << "w,p,f=" << fmt.width << ", " << fmt.precision << ", " 
        << fmt.fillChar << ", flags=" << fmt.flags;
    return out;
}

}

#endif /*STREAM_FMT_OUT_HPP_*/
