import fs from 'node:fs'
import path from 'node:path'

const mdnSrc = 'dep/content/files/en-us/web/css/reference/properties/index.md'
const mdnPath = path.join(path.dirname(__dirname), mdnSrc)

const imbaSrc = 'dep/imba/packages/imba/src/compiler/styler.mjs'
const imbaPath = path.join(path.dirname(__dirname), imbaSrc)

const outFile = 'src/completion/css/properties.imba'
const outPath = path.join(path.dirname(__dirname), outFile)
fs.readFile(mdnPath, 'utf8', do(err, data)
	if err 
		console.error('Error reading file:', err)
		return
	let startPoint = (data.match(/###\s+A/)).index
	data = data.slice(startPoint)
	let properties\String[] = data.match(/CSSxRef\(".*"\)/g);
	properties = properties.map(do(p) p.match(/"([^"]*)"/)[1]);
	

	fs.readFile(imbaPath, 'utf8', do(imbaErr, imbaData)
		if imbaErr
			console.error('Error reading file:', err)
			return
		let imbaPropsText = imbaData.match(/export\s+const\s+aliases\s+\=\s+({(.|\n)*};)(.|\n)*export\s+const\s+abbreviations/)[1];
		let imbaProperties = imbaPropsText
			.split(/\r?\n/)
			.filter(do(l) l.includes(":"))
			.map(do(l) l.trim().replace(/\/\/.*/, ""))
			.filter(do(l) l.trim())
			.map(do(l) 
				let [alias, property] = l.replace(/,$/, "").split(":")
				return {
					alias: alias.trim().replace(/'/g, ''),
					property: JSON.parse(property.replace(/'/g, '"').trim())
				}
			)
		
		for prop of imbaProperties
			if typeof prop.property == "string" and prop.property != prop.alias and !properties.includes(prop.property) and imbaProperties.find(do(p) p.alias == prop.property) == null
				imbaProperties.push({alias: prop.property, property: prop.alias})

		const propertyItems = properties.map(do(p)
			const aliases = imbaProperties
				.filter(do(a) 
					if (typeof a.property == "string")
						return a.property == p
					else
						return a.property.includes(p)
				)
				.map(do(a) a.alias);
			return "\{label: \"{p}\", documentation: \"{aliases.join(", ")}\", kind: CompletionItemKind.Property\}"
		)
		const imbaPropertyItems = imbaProperties.map(do(p)
			let doc = typeof p.property == "string" ? p.property : p.property.join(", ")
			return "\{label: \"{p.alias}\", documentation: \"{doc}\", kind: CompletionItemKind.Property\}"
		)

		const allProps = propertyItems.concat(imbaPropertyItems)
		const file = [
			"# This is a generated file, see scripts/getCSSProperties.imba\n"
			"import \{CompletionItemKind\} from 'vscode';\n"
			"\n"
			"export const properties = [\n\t"
			allProps.join("\n\t")
			"\n]"
		]
		fs.mkdir(path.dirname(outPath), { recursive: true }, do(err)
			if err
				console.log("Could not create css output directory", err)
		)
		fs.writeFile(outPath, file.join(""), "utf8", do(err)
			if err
				console.log("Could not create properties file", err)
			console.log("generated {outFile}")
		)
	)
);