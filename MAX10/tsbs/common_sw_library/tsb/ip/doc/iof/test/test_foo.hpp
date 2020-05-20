#ifndef FOO_H
#define FOO_H


struct Foo
{
    int ii;
    int cc;
    Foo(): ii(543), cc(987) {}
    Foo(int ii, int cc): ii(ii), cc(cc) {}
    bool operator==(const Foo& rhs) const {return ii == rhs.ii && cc == rhs.cc;}
};


inline std::ostream& 
operator<<(std::ostream& out, const Foo& foo)
{
    out << foo.ii << ", " << foo.cc;
    return out;
}


inline std::istream& 
operator>>(std::istream& in, Foo& foo)
{
    in >> foo.ii;
    in.ignore(1); 
    in >> foo.cc;
    return in;
}


#endif // FOO_H

