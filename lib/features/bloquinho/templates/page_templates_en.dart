/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

class PageTemplatesEn {
  static const String rootPageTemplate = '''# 📊 Complete Markdown Document with All Features

## 🎨 Color and Formatting Demonstration

This document exemplifies **all main functionalities** of Markdown, including <span style="color:red; background-color:#ffeeee; padding:2px 5px; border-radius:3px">**custom colors**</span> and advanced formatting

### Examples of <span style="background-color:#0000FF; color:#FFFFFF">Colored</span> Text

Here we have different text styles:

- <span style="color:red">**Red bold text**</span>
- <span style="color:blue; font-style:italic">Blue italic text</span>
- <span style="color:white; background-color:green; padding:3px 8px; border-radius:5px">✅ Success</span>
- <span style="color:white; background-color:red; padding:3px 8px; border-radius:5px">❌ Error</span>
- <span style="color:orange; background-color:#fff3cd; padding:3px 8px; border-radius:5px">⚠️ Warning</span>


## 📝 Heading Hierarchy

# Level 1 Heading

## Level 2 Heading

### Level 3 Heading

#### Level 4 Heading

##### Level 5 Heading

###### Level 6 Heading

### Alternative Headings

Main Title
==========

Subtitle
--------

## 💻 Code Examples

### Python Code

```python
def calculate_fibonacci(n):
    """Calculate the Fibonacci sequence up to n terms"""
    if n <= 0:
        return []
    elif n == 1:
        return [0]
    elif n == 2:
        return [0, 1]
    
    fib = [0, 1]
    for i in range(2, n):
        fib.append(fib[i-1] + fib[i-2])
    
    return fib

# Usage example
result = calculate_fibonacci(10)
```


### JavaScript Code

```javascript
// Class to manage users
class UserManager {
    constructor() {
        this.users = [];
    }
    
    addUser(name, email) {
        const user = {
            id: Date.now(),
            name: name,
            email: email,
            active: true
        };
        this.users.push(user);
        return user;
    }
    
    findUser(id) {
        return this.users.find(u => u.id === id);
    }
}

// Using the class
const manager = new UserManager();
const newUser = manager.addUser("John", "john@email.com");
console.log(newUser);
```


### SQL Code

```sql
-- Table creation and advanced queries
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    product VARCHAR(100) NOT NULL,
    price DECIMAL(10,2),
    sale_date DATE,
    seller_id INTEGER
);

-- Query with aggregations
SELECT 
    seller_id,
    COUNT(*) as total_sales,
    SUM(price) as total_revenue,
    AVG(price) as average_price,
    MAX(sale_date) as last_sale
FROM sales 
WHERE sale_date >= '2025-01-01'
GROUP BY seller_id
HAVING SUM(price) > 1000
ORDER BY total_revenue DESC;
```


### Inline Code

To run the script, use the command <span style="color:white; background-color:black; padding:2px 5px; border-radius:3px; font-family:monospace">python app.py</span> in the terminal.

## 🔢 Mathematical Formulas (LaTeX)

### Inline Formulas

Einstein's famous equation: \$E = mc^2\$

The quadratic formula: \$x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}\$

### Block Formulas

Definite integral:

\$
\\int_a^b f(x) \\, dx = F(b) - F(a)
\$

Summation:

\$
\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}
\$

### Matrices

\$\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}\$

## 📊 Advanced Tables

### Monthly Sales Table

| Month | Sales | Target | <span style="color:green">%Achieved</span> | Status |
| :-- | :-- | :-- | :-- | :-- |
| January | €15,000 | €12,000 | <span style="color:green; font-weight:bold">125%</span> | <span style="color:white; background-color:green; padding:2px 6px; border-radius:3px">✅ Exceeded</span> |
| February | €10,500 | €12,000 | <span style="color:orange; font-weight:bold">87.5%</span> | <span style="color:white; background-color:orange; padding:2px 6px; border-radius:3px">⚠️ Below</span> |
| March | €14,200 | €12,000 | <span style="color:green; font-weight:bold">118%</span> | <span style="color:white; background-color:green; padding:2px 6px; border-radius:3px">✅ Exceeded</span> |

## 📋 Lists and Tasks

### Project Task List

- [x] <span style="color:green">**Requirements analysis**</span> ✅
- [x] <span style="color:green">**Interface design**</span> ✅
- [ ] <span style="color:orange">**Backend development**</span> 🔄
    - [x] Database configuration
    - [x] Authentication API
    - [ ] User API
    - [ ] Reports API
- [ ] <span style="color:red">**Testing**</span> ⏳
- [ ] <span style="color:red">**Deployment**</span> ⏳

## 📈 Diagrams

### Process Flowchart

```mermaid
graph TD
    A[Start] --> B{Valid login?}
    B -->|Yes| C[Dashboard]
    B -->|No| D[Error screen]
    C --> E{User type?}
    E -->|Admin| F[Admin Panel]
    E -->|User| G[User Panel]
    F --> H[Reports]
    G --> I[Profile]
    H --> J[End]
    I --> J
    D --> A
```

## 💬 Quotes and Highlights

### Simple Quote

> "The best way to predict the future is to create it."
> — Peter Drucker

### Highlight Box

<span style="background-color:#e1f5fe; border-left:4px solid #0277bd; padding:10px; display:block; margin:10px 0;">
<strong>💡 Important Tip:</strong><br>
Always backup your data before performing important system updates.
</span>

## 🔗 Links and References

### Basic Links

- [Markdown Documentation](https://www.markdownguide.org)
- [Mermaid Diagrams](https://mermaid.js.org/)
- [LaTeX Mathematics](https://katex.org/)

## 📝 Paragraphs and Formatting

### Text with Mixed Formatting

This paragraph demonstrates **bold text**, *italic text*, ***bold and italic text***, ~~strikethrough text~~, and `inline code`.

We can also have <span style="color:blue; text-decoration:underline">blue underlined text</span>, <span style="background-color:yellow">highlighted text</span>, and <span style="color:red; font-weight:bold">red bold text</span>.

## 🏁 Conclusion

This document demonstrates the versatility and power of Markdown when combined with HTML and other technologies. With these techniques, it's possible to create rich, colorful, and interactive documentation that goes far beyond simple text.

<span style="background-color:#e8f5e8; border:1px solid #4caf50; border-radius:5px; padding:15px; display:block; margin:20px 0;">
<strong style="color:#2e7d32;">✅ Complete Document</strong><br>
This example includes all main functionalities of modern Markdown, serving as a complete reference for creating professional documents.
</span>

*Document created - Guimarães, Portugal* 🇵🇹
''';

  static const String newPageTemplate = '''# New Page

## Introduction

Welcome to your new page! Here you can start writing your content.

### What you can do:

- Write text in **bold** and *italic*
- Create lists
- Add code
- Insert mathematical formulas
- Create tables
- And much more!

### Code Example

```dart
void main() {
  // Hello, world!
}
```

### Task List

- [ ] First task
- [ ] Second task
- [ ] Third task

> **Tip:** Use the formatting menu to add more elements to your page.
''';

}