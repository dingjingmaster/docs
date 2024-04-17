## LangChain快速上手

LangChain是一个用于开发由大型语言模型（LLM）提供支持的应用程序的框架。

LangChain简化了LLM应用程序生命周期的每个阶段：
- 开发：使用LangChain的开源构建块和组件构建您的应用程序。
- 产品化：使用LangSmith来检查、监控和评估您的链，以便您可以不断优化和部署。
- 部署：使用LangServe将任何链转化为API。

![](img/lc-1.svg)

具体而言，该框架由以下开源库组成：
- langchain核心：基础抽象和langchain表达式语言。
- langchain社区：第三方集成。
    - 合作伙伴包（例如langchain-openai、langchain-anthropic等）：一些集成已被进一步拆分为自己的轻量级包，这些包仅依赖于langchain-core。
- langchain：构成应用程序认知架构的链、代理和检索策略。
- langgraph：通过将步骤建模为图中的边和节点，使用LLM构建健壮且有状态的多参与者应用程序。
- langserve：将LangChain链部署为RESTAPI。

更广泛的生态系统包括：
- LangSmith：一个开发人员平台，允许您调试、测试、评估和监控LLM应用程序，并与LangChain无缝集成。

### 安装

#### 安装Jupyter Notebook

Jupyter Notebook 作为开发LLM的编辑工具。

#### 安装 LangChain

```shell
pip install langchain
```

或 conda
```shell
conda install langchain -c conda-forge
```

#### 配置LangSmith

使用LangChain构建的许多应用程序将包含多个步骤，其中包含多次LLM调用调用。随着这些应用程序变得越来越复杂，能够检查链或代理内部到底发生了什么变得至关重要。最好的方法是与LangSmith合作。

请注意，LangSmith不是必需的，但它是有帮助的。如果您确实想使用LangSmith，在上面的链接注册后，请确保将环境变量设置为开始记录跟踪：

```
export LANGCHAIN_TRACING_V2="true"
export LANGCHAIN_API_KEY="..."
```

#### 使用LangChain构建

LangChain支持构建将外部数据和计算源连接到LLM的应用程序。在这个快速入门中，我们将介绍几种不同的方法。我们将从一个简单的LLM链开始，它只依赖于提示模板中的信息来响应。接下来，我们将构建一个检索链，它从一个单独的数据库中获取数据，并将其传递到提示模板中。然后，我们将添加聊天历史记录，以创建一个会话检索链。这允许您以聊天的方式与此LLM进行交互，因此它可以记住以前的问题。最后，我们将构建一个代理，它利用LLM来确定是否需要获取数据来回答问题。我们将高水平地报道这些，但所有这些都有很多细节！我们将链接到相关文档。

##### OpenAI

使用 OpenAI 提供的模型API来访问大模型：

导入
```
pip install langchain-openai
```

访问API需要API密钥，您可以通过在此处创建帐户和标题来获得该密钥。一旦我们有了密钥，我们就想通过运行以下命令将其设置为环境变量：

```
export OPENAI_API_KEY="..."

```

初始化模型
```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI()
```

如果您不希望设置环境变量，则可以在启动OpenAI LLM类时通过api_key命名参数直接传入密钥：

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(api_key="...")
```

一旦您安装并初始化了您选择的LLM，我们就可以尝试使用它！

```python
llm.invoke("how can langsmith help with testing?")
```

我们还可以使用提示模板来指导其响应。提示模板将原始用户输入转换为LLM的更好输入。

```python
from langchain_core.prompts import ChatPromptTemplate
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are world class technical documentation writer."),
    ("user", "{input}")
])
```

我们现在可以将这些组合成一个简单的LLM链：

```python
chain = prompt | llm
```

我们现在可以援引它并提出同样的问题。它仍然不知道答案，但对于技术作家来说，它应该以更恰当的语气回应！

```python
chain.invoke({"input": "how can langsmith help with testing?"})
```

ChatModel的输出（因此也是这个链的输出）是一条消息。然而，使用字符串通常要方便得多。让我们添加一个简单的输出解析器，将聊天消息转换为字符串。

```python
from langchain_core.output_parsers import StrOutputParser

output_parser = StrOutputParser()
```

我们现在可以将其添加到上一个链中：

```python
chain = prompt | llm | output_parser
```

我们现在可以援引它并提出同样的问题。答案现在将是一个字符串（而不是ChatMessage）。

```python
chain.invoke({"input": "how can langsmith help with testing?"})
```

##### 本地Ollama

Ollama允许您在本地运行开源的大型语言模型，如Llama 2。

下载Ollama后拉取大模型：
```shell
ollama pull llama2
```

然后，确保Ollama服务器正在运行。之后，您可以执行以下操作：
```python
from langchain_community.llms import Ollama
llm = Ollama(model="llama2")
```

一旦您安装并初始化了您选择的LLM，我们就可以尝试使用它！让我们问一下LangSmith是什么——这是训练数据中没有的东西，所以它不应该有很好的反应。

```python
llm.invoke("how can langsmith help with testing?")
```

我们还可以使用提示模板来指导其响应。提示模板将原始用户输入转换为LLM的更好输入。

```python
from langchain_core.prompts import ChatPromptTemplate
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are world class technical documentation writer."),
    ("user", "{input}")
])
```

我们现在可以将这些组合成一个简单的LLM链：
```python
chain = prompt | llm
```

我们现在可以援引它并提出同样的问题。它仍然不知道答案，但对于技术作家来说，它应该以更恰当的语气回应！
```python
chain.invoke({"input": "how can langsmith help with testing?"})
```

ChatModel的输出（因此也是这个链的输出）是一条消息。然而，使用字符串通常要方便得多。让我们添加一个简单的输出解析器，将聊天消息转换为字符串。

```python
from langchain_core.output_parsers import StrOutputParser

output_parser = StrOutputParser()
```

我们现在可以将其添加到上一个链中：

```python
chain = prompt | llm | output_parser
```
我们现在可以援引它并提出同样的问题。答案现在将是一个字符串（而不是ChatMessage）。

```python
chain.invoke({"input": "how can langsmith help with testing?"})
```

----------

我们现在已经成功地建立了一个基本的LLM链。我们只谈到了提示、模型和输出解析器的基本知识——要更深入地了解这里提到的一切，请继续阅读。

### 检索链

为了正确回答最初的问题（“langsmith如何帮助测试？”），我们需要为LLM提供额外的上下文。我们可以通过检索来做到这一点。当您有太多的数据要直接传递给LLM时，检索非常有用。然后，您可以使用检索器只提取最相关的片段并将其传递进去。

在这个过程中，我们将从Retriever中查找相关文档，然后将它们传递到提示符中。Retriever可以由任何东西支持——SQL表、互联网等——但在这种情况下，我们将填充一个向量存储，并将其用作Retriever。有关矢量存储的更多信息，请参阅本文档。

首先，我们需要加载要索引的数据。为此，我们将使用WebBaseLoader。这需要安装BeautifulSoup：

```shell
pip install beautifulsoup4
```

之后，我们可以导入并使用WebBaseLoader。

```python
from langchain_community.document_loaders import WebBaseLoader
loader = WebBaseLoader("https://docs.smith.langchain.com/user_guide")

docs = loader.load()
```

接下来，我们需要将其索引到向量库中。这需要几个组件，即嵌入模型和向量库。

对于嵌入模型，我们再次提供了通过API或运行本地模型进行访问的示例。

> 以下全部由Ollma本地模型提供服务

```python
from langchain_community.embeddings import OllamaEmbeddings

embeddings = OllamaEmbeddings()
```

现在，我们可以使用这个嵌入模型将文档摄取到向量库中。为了简单起见，我们将使用一个简单的本地向量库FAISS。

首先，我们需要为此安装所需的软件包：

```shell
pip install faiss-cpu
```

然后我们可以建立我们的索引：

```python
from langchain_community.vectorstores import FAISS
from langchain_text_splitters import RecursiveCharacterTextSplitter


text_splitter = RecursiveCharacterTextSplitter()
documents = text_splitter.split_documents(docs)
vector = FAISS.from_documents(documents, embeddings)
```

现在我们已经在向量库中对这些数据进行了索引，我们将创建一个检索链。该链将接受一个传入的问题，查找相关文档，然后将这些文档与原始问题一起传递到LLM中，并要求其回答原始问题。

首先，让我们建立一个链，它接受一个问题和检索到的文档并生成一个答案。

```python
from langchain.chains.combine_documents import create_stuff_documents_chain

prompt = ChatPromptTemplate.from_template("""Answer the following question based only on the provided context:

<context>
{context}
</context>

Question: {input}""")

document_chain = create_stuff_documents_chain(llm, prompt)
```

如果我们愿意，我们可以通过直接传递文档来自己运行：

```python
from langchain_core.documents import Document

document_chain.invoke({
    "input": "how can langsmith help with testing?",
    "context": [Document(page_content="langsmith can let you visualize test results")]
})
```

然而，我们希望文档首先来自我们刚刚设置的检索器。这样，我们就可以使用检索器动态地选择最相关的文档，并将它们传递给给定的问题。

```python
from langchain.chains import create_retrieval_chain

retriever = vector.as_retriever()
retrieval_chain = create_retrieval_chain(retriever, document_chain)
```

我们现在可以调用这个链。这将返回一个字典-LLM的响应在答案键中

```python
response = retrieval_chain.invoke({"input": "how can langsmith help with testing?"})
print(response["answer"])

# LangSmith offers several features that can help with testing:...
```

这个答案应该更准确！

### 会话检索链

到目前为止，我们创建的链只能回答单个问题。人们正在构建的LLM应用程序的主要类型之一是聊天机器人。那么，我们如何将这条链转化为一条可以回答后续问题的链呢？

我们仍然可以使用`create_retrieval_chain`函数，但我们需要更改两件事：
- 检索方法现在不应该只针对最近的输入，而是应该考虑整个历史。
- 最后的LLM链同样应考虑整个历史

#### 更新检索

为了更新检索，我们将创建一个新的链。该链将接收最近的输入（input）和会话历史（chat_history），并使用LLM生成搜索查询。

```python
from langchain.chains import create_history_aware_retriever
from langchain_core.prompts import MessagesPlaceholder

# First we need a prompt that we can pass into an LLM to generate this search query

prompt = ChatPromptTemplate.from_messages([
    MessagesPlaceholder(variable_name="chat_history"),
    ("user", "{input}"),
    ("user", "Given the above conversation, generate a search query to look up to get information relevant to the conversation")
])
retriever_chain = create_history_aware_retriever(llm, retriever, prompt)
```

我们可以通过传递一个用户提出后续问题的实例来测试这一点。

```python
from langchain_core.messages import HumanMessage, AIMessage

chat_history = [HumanMessage(content="Can LangSmith help test my LLM applications?"), AIMessage(content="Yes!")]
retriever_chain.invoke({
    "chat_history": chat_history,
    "input": "Tell me how"
})
```

您应该看到，这会返回有关LangSmith中测试的文档。这是因为LLM生成了一个新的查询，将聊天历史记录与后续问题相结合。

现在我们有了这个新的检索器，我们可以创建一个新的链来继续对话，记住这些检索到的文档。

```python
prompt = ChatPromptTemplate.from_messages([
    ("system", "Answer the user's questions based on the below context:\n\n{context}"),
    MessagesPlaceholder(variable_name="chat_history"),
    ("user", "{input}"),
])
document_chain = create_stuff_documents_chain(llm, prompt)

retrieval_chain = create_retrieval_chain(retriever_chain, document_chain)
```

我们现在可以端到端测试：

```python
chat_history = [HumanMessage(content="Can LangSmith help test my LLM applications?"), AIMessage(content="Yes!")]
retrieval_chain.invoke({
    "chat_history": chat_history,
    "input": "Tell me how"
})
```

我们可以看到，这给出了一个连贯的答案——我们已经成功地将我们的检索链变成了聊天机器人！

### 代理

到目前为止，我们已经创建了链的例子——每一步都是提前知道的。我们将创建的最后一件事是一个代理——LLM在其中决定要采取的步骤。

> 注意：对于这个例子，我们将只展示如何使用OpenAI模型创建代理，因为本地模型还不够可靠。

构建代理时要做的第一件事是决定它应该访问哪些工具。对于本例，我们将授予代理访问两个工具的权限：
- 能够轻松回答有关LangSmith的问题
- 一个搜索工具。这将使它能够轻松回答需要最新信息的问题。

首先，让我们为刚刚创建的检索器设置一个工具：

```python
from langchain.tools.retriever import create_retriever_tool

retriever_tool = create_retriever_tool(
    retriever,
    "langsmith_search",
    "Search for information about LangSmith. For any questions about LangSmith, you must use this tool!",
)
```

我们将使用的搜索工具是Tavily。这将需要一个API密钥（他们免费）。在他们的平台上创建后，您需要将其设置为环境变量：

```python
export TAVILY_API_KEY=...
```

如果您不想设置API密钥，您可以跳过创建此工具。

```python
from langchain_community.tools.tavily_search import TavilySearchResults

search = TavilySearchResults()
```

我们现在可以创建一个要使用的工具列表：

```python
tools = [retriever_tool, search]
```

现在我们有了这些工具，我们可以创建一个代理来使用它们。我们将很快对此进行介绍-要更深入地了解到底发生了什么，请查看Agent的入门文档

先安装 langchain hub：
```shell
pip install langchainhub
```

安装langchain openai包要与openai交互，我们需要使用与openai SDK连接的langchain openai[https://github.com/langchain-ai/langchain/tree/master/libs/partners/openai].

```shell
pip install langchain-openai
```

现在我们可以使用它来获得预定义的提示

```python
from langchain_openai import ChatOpenAI
from langchain import hub
from langchain.agents import create_openai_functions_agent
from langchain.agents import AgentExecutor

# Get the prompt to use - you can modify this!
prompt = hub.pull("hwchase17/openai-functions-agent")

# You need to set OPENAI_API_KEY environment variable or pass it as argument `api_key`.
llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)
agent = create_openai_functions_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
```

我们现在可以调用代理，看看它是如何响应的！我们可以向它询问有关LangSmith的问题：

```python
agent_executor.invoke({"input": "how can langsmith help with testing?"})
```

我们可以问一下天气：

```python
agent_executor.invoke({"input": "what is the weather in SF?"})
```

我们可以与它进行对话：

```python
chat_history = [HumanMessage(content="Can LangSmith help test my LLM applications?"), AIMessage(content="Yes!")]
agent_executor.invoke({
    "chat_history": chat_history,
    "input": "Tell me how"
})
```

### 使用LangServe服务

现在我们已经构建了一个应用程序，我们需要为它提供服务。这就是LangServe的用武之地。LangServe帮助开发人员将LangChain链部署为REST API。您不需要使用LangServe即可使用LangChain，但在本指南中，我们将展示如何使用LangServe部署您的应用程序。

虽然本指南的第一部分旨在在Jupyter中运行，但我们现在将不再赘述。我们将创建一个Python文件，然后从命令行与之交互。

```shell
pip install "langserve[all]"
```

#### 服务

为了为我们的应用程序创建一个服务器，我们将制作一个serve.py文件。这将包含我们为应用程序提供服务的逻辑。它包括三件事：
1. 我们刚刚在上面构建的链的定义
2. 我们的FastAPI应用程序
3. 为链提供服务的路由的定义，使用langserve.add_routes完成

```python
#!/usr/bin/env python
from typing import List

from fastapi import FastAPI
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from langchain_community.document_loaders import WebBaseLoader
from langchain_openai import OpenAIEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain.tools.retriever import create_retriever_tool
from langchain_community.tools.tavily_search import TavilySearchResults
from langchain import hub
from langchain.agents import create_openai_functions_agent
from langchain.agents import AgentExecutor
from langchain.pydantic_v1 import BaseModel, Field
from langchain_core.messages import BaseMessage
from langserve import add_routes

# 1. Load Retriever
loader = WebBaseLoader("https://docs.smith.langchain.com/user_guide")
docs = loader.load()
text_splitter = RecursiveCharacterTextSplitter()
documents = text_splitter.split_documents(docs)
embeddings = OpenAIEmbeddings()
vector = FAISS.from_documents(documents, embeddings)
retriever = vector.as_retriever()

# 2. Create Tools
retriever_tool = create_retriever_tool(
    retriever,
    "langsmith_search",
    "Search for information about LangSmith. For any questions about LangSmith, you must use this tool!",
)
search = TavilySearchResults()
tools = [retriever_tool, search]


# 3. Create Agent
prompt = hub.pull("hwchase17/openai-functions-agent")
llm = ChatOpenAI(model="gpt-3.5-turbo", temperature=0)
agent = create_openai_functions_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)


# 4. App definition
app = FastAPI(
  title="LangChain Server",
  version="1.0",
  description="A simple API server using LangChain's Runnable interfaces",
)

# 5. Adding chain route

# We need to add these input/output schemas because the current AgentExecutor
# is lacking in schemas.

class Input(BaseModel):
    input: str
    chat_history: List[BaseMessage] = Field(
        ...,
        extra={"widget": {"type": "chat", "input": "location"}},
    )


class Output(BaseModel):
    output: str

add_routes(
    app,
    agent_executor.with_types(input_type=Input, output_type=Output),
    path="/agent",
)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="localhost", port=8000)
```

就这样！如果我们执行此文件：

```python
python serve.py
```

我们应该看到我们的链在localhost:8000上提供服务。

每个LangServe服务都有一个简单的内置UI，用于配置和调用具有流输出和中间步骤可见性的应用程序。前往http://localhost:8000/agent/playground/尝试一下！输入与之前相同的问题——“langsmith如何帮助测试？”——它的回答应该与之前相同。

#### 客户端

现在，让我们设置一个客户端，以便以编程方式与我们的服务进行交互。我们可以使用[langserve.RemoteRunnable]（/docs/langserve#客户端）轻松完成此操作。使用它，我们可以像在客户端运行一样与服务链进行交互。

```python
from langserve import RemoteRunnable

remote_chain = RemoteRunnable("http://localhost:8000/agent/")
remote_chain.invoke({
    "input": "how can langsmith help with testing?",
    "chat_history": []  # Providing an empty list as this is the first call
})
```

要了解更多关于LangServe的其他功能，[请点击此处](https://python.langchain.com/docs/langserve/)。

### 下一步

我们已经谈到了如何使用LangChain构建应用程序，如何使用LangSmith跟踪应用程序，以及如何使用LangServe为其提供服务。这三个方面的功能比我们在这里介绍的要多得多。要继续您的旅程，我们建议您阅读以下内容（按顺序）：

- 所有这些功能都由LangChain表达式语言（LCEL）支持，这是一种将这些组件链接在一起的方式。查看该文档以更好地了解如何创建自定义链。
- 模型IO：涵盖了提示、LLM和输出解析器的更多细节。
- 检索：涵盖了与检索相关的所有内容的更多细节
- 代理：涵盖与代理相关的所有细节
- 探索常见的端到端用例和模板应用程序
- 阅读LangSmith，用于调试、测试、监控等的平台
- 了解有关使用LangServe为应用程序提供服务的更多信息
