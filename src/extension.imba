import {commands, window, languages, CompletionItem, CompletionItemKind, SnippetString, MarkdownString} from 'vscode';
import type {ExtensionContext, TextDocument, Position, CancellationToken, CompletionContext} from 'vscode';

const tags = [
	{name: "h1", doc: "HTMLHeadingElement", kind: CompletionItemKind.Class}
	{name: "h2", doc: "HTMLHeadingElement", kind: CompletionItemKind.Class}
	{name: "h3", doc: "HTMLHeadingElement", kind: CompletionItemKind.Class}
	{name: "h4", doc: "HTMLHeadingElement", kind: CompletionItemKind.Class}
	{name: "h5", doc: "HTMLHeadingElement", kind: CompletionItemKind.Class}
	{name: "h6", doc: "HTMLHeadingElement", kind: CompletionItemKind.Class}
]

class ImbaCompletionProvider
	def provideCompletionItems(doc\TextDocument, pos\Position, tok\CancellationToken, ctx\CompletionContext)
		const items\CompletionItem[] = [];
		const headings = [];
		for htmlTag of tags
			const item = new CompletionItem(htmlTag.name, htmlTag.kind)
			if htmlTag.snippet
				item.insertText = new SnippetString(htmlTag.snippet)
			if htmlTag.doc
				item.documentation = new MarkdownString(htmlTag.doc)
			items.push(item)
		return items
	# def resolveCompletionItem

export def activate(context\ExtensionContext) 
	console.log('Congratulations, your extension "imba-web" is now active in the web extension host!')
	const disposable = commands.registerCommand('imba-language-support.helloWorld', do
		window.showInformationMessage('Hello World from imba-web in a web extension host!')
	)
	const imbaSelector =
		scheme: "file"
		language: "imba"
	const triggerCharacters = ['<']
	const provider = languages.registerCompletionItemProvider(imbaSelector, new ImbaCompletionProvider, ...triggerCharacters)
	context.subscriptions.push(disposable, provider)

export def deactivate