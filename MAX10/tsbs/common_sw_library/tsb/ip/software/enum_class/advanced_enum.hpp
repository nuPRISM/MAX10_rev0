#include <functional>
#include <set>
 
template <class TValue, class T>
class Tmpl_Enum {
 
private:
 
 // Constructors
 explicit Tmpl_Enum(const TValue& Value);
 
 // Predicate for finding the corresponding instance
 struct Enum_Predicate_Corresponds:
    public std::unary_function<const Tmpl_Enum<TValue, T>*, bool> {
 
      Enum_Predicate_Corresponds(const TValue& Value): m_value(Value) { 
}
      bool operator()(const Tmpl_Enum<TValue, T>* E)
      { return E->Get_Value() == m_value; }
 
    private:
      const TValue& m_value;
 };
 
 // Comparison functor for the set of instances
 struct Enum_Ptr_Less:
    public std::binary_function<const Tmpl_Enum<TValue, T>*, const Tmpl_Enum<TValue, T>*, bool> {
      bool operator()(const Tmpl_Enum<TValue, T>* E_1, const Tmpl_Enum<TValue, T>* E_2)
      { return E_1->Get_Value() < E_2->Get_Value(); }
 };
 
public:
 // Compiler-generated copy constructor and operator= are OK.
 
 typedef std::set<const Tmpl_Enum<TValue, T>*, Enum_Ptr_Less> instances_list;
 typedef instances_list::const_iterator const_iterator;
 
 // Access to TValue value
 const TValue& Get_Value(void) const { return m_value; }
 static const TValue& Min(void) { return (*s_instances.begin())->m_value; }
 static const TValue& Max(void) { return (*s_instances.rbegin())->m_value; }
 static const Tmpl_Enum<TValue, T>* Corresponding_Enum(const TValue& Value)
 { const_iterator it = find_if(s_instances.begin(), s_instances.end(), Enum_Predicate_Corresponds(Value));
    return (it != s_instances.end()) ? *it : NULL; }
 static bool Is_Valid_Value(const TValue& Value) { return Corresponding_Enum(Value) != NULL; }
 
 // Number of elements
 static instances_list::size_type size(void) { return s_instances.size(); }
 
 // Iteration
 static const_iterator begin(void) { return s_instances.begin(); }
 static const_iterator end(void) { return s_instances.end(); }
 
private:
 TValue m_value;
 
 static instances_list s_instances;
};
 
 
template <class TValue, class T>
inline Tmpl_Enum<TValue, T>::Tmpl_Enum(const TValue& Value):
 m_value(Value)
{
 s_instances.insert(this);
}