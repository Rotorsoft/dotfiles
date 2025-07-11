const fs = require("fs")
const path = require("path")

// Paths
const vscodeWorkbenchPath = path.join(
  process.env.HOME,
  "Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/code/electron-browser/workbench"
)
const workbenchFile = path.join(vscodeWorkbenchPath, "workbench.html")
const backupFile = `${workbenchFile}.bak`
const customCss = path.join(process.cwd(), "vscode-custom.css")
const targetCss = path.join(vscodeWorkbenchPath, "vscode-custom.css")

// Check if the workbench file exists
if (!fs.existsSync(workbenchFile)) {
  console.error(`Error: workbench.html not found at ${workbenchFile}`)
  process.exit(1)
}

// Check if the custom CSS file exists
if (!fs.existsSync(customCss)) {
  console.error(`Error: ${customCss} not found in the current directory`)
  process.exit(1)
}

// Backup the original workbench.html file if not already backed up
if (!fs.existsSync(backupFile)) {
  console.log("Backing up the original workbench.html file...")
  fs.copyFileSync(workbenchFile, backupFile)
  console.log(`Backup created at ${backupFile}`)
} else {
  console.log(`Backup already exists at ${backupFile}`)
}

// Copy the custom CSS file to the workbench directory
fs.copyFileSync(customCss, targetCss)
console.log(`Copied custom CSS to ${targetCss}`)

// Read the workbench.html file
let workbenchHtml = fs.readFileSync(backupFile, "utf-8")

// Check if the custom CSS link is already present
if (!workbenchHtml.includes('href="vscode-custom.css"')) {
  // Insert a reference to the custom CSS file
  const cssLink = `<link rel="stylesheet" href="vscode-custom.css">`
  workbenchHtml = workbenchHtml.replace("</head>", `${cssLink}\n</head>`)
}

// Write the modified HTML back to the workbench.html file
fs.writeFileSync(workbenchFile, workbenchHtml)
console.log(`Modified workbench.html successfully created at ${workbenchFile}`)
console.log("Done! Restart Visual Studio Code to see the changes.")
