

// generate-wiki-index.js
const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');

const WIKI_DIRECTORY = path.join(__dirname, 'Site', 'wiki');
const OUTPUT_FILENAME = 'wiki_index.json';

// Função para extrair o título de um ficheiro HTML
function extractTitle(filePath) {
    try {
        const htmlContent = fs.readFileSync(filePath, 'utf-8');
        const dom = new JSDOM(htmlContent);
        const doc = dom.window.document;

        // Tenta encontrar o título em h1, depois em h2, e finalmente no <title> da página
        const h1 = doc.querySelector('h1');
        if (h1 && h1.textContent.trim()) {
            return h1.textContent.trim();
        }
        const h2 = doc.querySelector('h2');
        if (h2 && h2.textContent.trim()) {
            return h2.textContent.trim();
        }
        const title = doc.querySelector('title');
        if (title && title.textContent.trim()) {
            return title.textContent.trim();
        }
        return path.basename(filePath); // Fallback para o nome do ficheiro
    } catch (e) {
        console.error(`Erro ao ler o título de ${filePath}:`, e);
        return path.basename(filePath); // Fallback em caso de erro
    }
}

function getWikiStructure(directory) {
    const structure = [];
    const items = fs.readdirSync(directory).sort();

    for (const item of items) {
        if (item === OUTPUT_FILENAME) continue;

        const itemPath = path.join(directory, item);
        const stat = fs.statSync(itemPath);

        if (stat.isDirectory()) {
            const children = getWikiStructure(itemPath);
            if (children.length > 0) {
                structure.push({
                    name: item,
                    type: 'folder',
                    children: children
                });
            }
        } else if (item.endsWith('.html')) {
            structure.push({
                name: item,
                type: 'file',
                path: path.relative(WIKI_DIRECTORY, itemPath).replace(/\\/g, '/'),
                title: extractTitle(itemPath) // Extrai o título
            });
        }
    }
    return structure;
}

function main() {
    console.log(`Scanning directory: ${WIKI_DIRECTORY}...`);
    const wikiStructure = getWikiStructure(WIKI_DIRECTORY);

    if (wikiStructure.length === 0) {
        console.log("No wiki structure to generate.");
        return;
    }

    const outputFile = path.join(WIKI_DIRECTORY, OUTPUT_FILENAME);

    try {
        fs.writeFileSync(outputFile, JSON.stringify(wikiStructure, null, 2), 'utf-8');
        console.log(`\n✅ Success! '${outputFile}' has been generated.`);
    } catch (error) {
        console.error(`\n❌ Error writing file: ${error}`);
    }
}

main();
