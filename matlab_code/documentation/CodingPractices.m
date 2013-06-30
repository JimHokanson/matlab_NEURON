%{

Coding practices

NAMING_STYLES
===========================================================================
1) properties    - lowercase_with_underscores
2) class names   - lowercase_with_underscores
3) class methods - lowerCamelCase
4) functions     - lowerCamelCase
5) constants     - UPPERCASE_WITH_UNDERSCORES

OPTIONAL INPUTS
===========================================================================
Try to minimize the use of optional inputs that are interpreted based on
the number of input arguments. Instead, use property/value pairs.

For optional inputs determined by spacing, include an asteriks when
defining the property and include specification of a default in the
definition. For property/value pairs, indicate in the definition by
varargin

EXAMPLE:

function myFunction(input_1,input_2,input_3,varargin)
%
%
%   myFunction(input_1,input_2,*input_3,varargin)
%   
%   INPUTS
%   ======================================================================
%   input_1 : Insert descriptions here 
%   input_2 :
%   input_3 : (default -1), 
%
%   OPTIONAL INPUTS (via property/value pairs)
%   =======================================================================

Other things ...
===========================================================================
# Call object methods using dot-calling:
    obj.myMethod();

# Include parentheses on method calls with no inputs
    see example above

# For similar assignments align equal signs
dim  = 'test';
size = 'cheese';

# Properties should be as concise as possible yet clear as to their
meaning.

# Try to limit the creation of properties of a class. For example, if the
property is only used in the constructor, it shouldn't be a property.

# All properties should be documented following their declaration in the
class.




%}