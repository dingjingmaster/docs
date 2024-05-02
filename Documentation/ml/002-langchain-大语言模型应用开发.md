## LangChain大语言模型应用开发

> 课程来源：LangChain作者的视频教程。作者在与LLM开发者交流时候发现可以从中有一些公共的抽象，于是诞生了LangChain。

LangChain 是一个用于构建LLM应用的开源开发框架。这个框架有两个API包，一个是Python、另一个是JavaScript(TypeScript)包。

LangChain 注重组合和模块化，可以将模块化组建链式组合成更完整的应用程序，并且非常容易上手。

### LangChain常见组件

- 模型：指基础的语言模型
- 提示：指创建输入，用来给模型传递信息的一种方式
- 解析器：解析器与“提示”相反，它接受模型的输出，并将输出结果解析成更结构化的格式，以便你可以对其进行后续操作。
- 索引：检索召回数据，并将数据与模型结合起来。
- 链：用来将更多的块串联起来。
- 代理：

使用模型过程中，人类反复的“提示”模型，“解析”模型输出，LangChain提供了一套简单的抽象来执行此类操作。

#### 模型、提示和解析器

```shell
import ollama

ollama.chat(model="llama3:instruct", messages=[{"role":"user", "content":"你是?请用中文回答。"}])
```
或者

```shell
from ollama import Client

client = Client(host="http://127.0.0.1:11434")
response = client.chat(model="llama3:instruct", messages=[
    {
        "role":"user",
        "content":"你好？",
    },
])
print(response)
```

此时完成一次与 llama3 的交互，并输出结果。

有时我们希望对输出结果进行格式化，以下是一个例子：

```python
from ollama import Client

def get_completion(prompt):
    client = Client(host="http://127.0.0.1:11434")
    resp = client.chat(model="llama3:instruct", messages=[
        {
            "role":"user",
            "content": prompt,
        },
    ])
    return resp


customer_email = ''' \
Arrr, I be fuming that me blender lid \
flew off and splattered me kitchen walls \
with smoothie! And to make matters worse, \
the warranty don't cover the cost of \
cleaning up me kitchen. I need yer help \
right now, matey!
'''

style = ''' \
American English \
in a calm and respectful tone
'''

# 使用 'f' 字符串和说明来指定提示.
# 把用三个反引号扩起来的文本翻译成"style"那样的风格。
prompt = f'''
Translate the text \
that is delimited by triple backticks \
into a style that is {style}.
text： ```{customer_email}```
'''

# 输出完整的提示语
print(prompt)

resp = get_completion(prompt)

print(resp['message']['content'])

```

输出：
```
Translate the text that is delimited by triple backticks into a style that is  American English in a calm and respectful tone
.
text： ``` Arrr, I be fuming that me blender lid flew off and splattered me kitchen walls with smoothie! And to make matters worse, the warranty don't cover the cost of cleaning up me kitchen. I need yer help right now, matey!
```

Here is the translation:

```I'm absolutely furious that my blender lid flew off and covered my kitchen walls in a mess of smoothie! And to make matters worse, the warranty doesn't cover the cost of cleaning up my kitchen. I really need your help right now.```

Let me know if you'd like any further adjustments!
```

这个例子中，把 `custom_email` 变量中原始的意思以另一种更为礼貌性的方式进行表达。

LangChain的模板用来取代上述的`f`字符串，这样在构建复杂的应用程序时候，提示语可能会很长且详细，模板是一种有用的抽象，可以帮助你在需要时重用好的提示。

下面是LangChain模板提示的例子
```python
# 以上通过llama3将不太礼貌的 `custom_email` 转变为更加礼貌性的表述。
# 假设现在要针对不同的语言来进行转换，这需要生成一整套针对不同语言的提示来生成这样的翻译。
# 接下来看看 LangChain 如何实现这一要求
from langchain.chat_models import ChatOllama

chat = ChatOllama(temperature=0.0)

# 为了反复使用上述模板，我们导入 LangChain 的 ChatPromptTemplate
from langchain.prompts import ChatPromptTemplate

template_string = prompt
prompt_template = ChatPromptTemplate.from_template(template_string)

customer_msg = prompt_template.format_messages(style=style, text=customer_email)
print(type(customer_msg))
print(type(customer_msg[0]))

print(customer_msg[0])
custer_resp = chat(customer_msg)

print(custer_resp)
```

LangChain为一些常见操作提供了提示，如：摘要、回答问题、连接到SQL数据库或连接到不同的API。通过使用LangChain的内置提示，你可以快速的使应用程序运行，而无需设计自己的提示。

LangChain的提示库的另一个方面是它还支持输出解析，稍后讲。

当使用LLM构建一个复杂的应用程序时候，你通常会提示LLM以某种格式生成输出，比如使用特定的关键词。

LangChain输出解析器提示模板：
- Thought: 思考
- Action: 动作
- Observation: 展示它从这个动作中观察到什么
- Thought： 
- Thought：
- Action： 

例子：从产品评论中提取信息，并讲输出格式化为JSON格式。
