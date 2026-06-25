import {commands, window, languages, CompletionItem, CompletionItemKind, SnippetString, MarkdownString} from 'vscode';
import type {ExtensionContext, TextDocument, Position, CancellationToken, CompletionContext} from 'vscode';
import {tags} from "./completion/html"
import {properties} from "./completion/css/properties"

class ImbaCompletionProvider
	def provideCompletionItems(doc\TextDocument, pos\Position, tok\CancellationToken, ctx\CompletionContext)
		const items\CompletionItem[] = [];
		const linePrefix = doc.lineAt(pos).text.substring(0, pos.character);
		const tagRegex = /<[a-zA-Z0-9]+[^>]*\[/
		# only render htmlTags if '<' is trigger
		if ctx.triggerCharacter != null and ctx.triggerCharacter == "<"
			for htmlTag of tags
				const item = new CompletionItem(htmlTag.name, htmlTag.kind)
				if htmlTag.snippet
					item.insertText = new SnippetString(htmlTag.snippet)
				if htmlTag.doc
					item.documentation = new MarkdownString(htmlTag.doc)
				items.push(item)
		# only show css properties if within html tag with opened inline style bracket
		# TODO: show css properties if within a css block
		# TODO: account for multi line inline styles
		if tagRegex.test(linePrefix)
			for property of properties
				const item = new CompletionItem(property.label, property.kind)
				item.documentation = property.documentation
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
	const triggerCharacters = ['<', ' ', '[']
	const provider = languages.registerCompletionItemProvider(imbaSelector, new ImbaCompletionProvider, ...triggerCharacters)
	context.subscriptions.push(disposable, provider)

export def deactivate