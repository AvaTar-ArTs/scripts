// ==UserScript==
// @name         Lyra Exporter Fetch
// @name:en      Lyra Exporter Fetch (One-Click AI Chat Backup)
// @description  一键导出 Claude/ChatGPT/Gemini/Google AI Studio/NotebookLM 对话记录（支持分支、PDF、长截图、SillyTavern）。保留完整对话分支、附加图片、LaTeX 公式、Artifacts、附件与思考过程。Lyra Exporter 的最佳搭档，打造您的本地 AI 知识库。
// @description:en One-click export for Claude, ChatGPT, Gemini , Google AI Studio & NotebookLM. Backups all chat branches, artifacts, and attachments. Exports to JSON/Markdown/PDF/Editable Screenshots. The ultimate companion for Lyra Exporter to build your local AI knowledge base.
// @namespace    userscript://lyra-conversation-exporter
// @version      7.5
// @homepage     https://github.com/Yalums/lyra-exporter/
// @supportURL   https://github.com/Yalums/lyra-exporter/issues
// @author       Yalums, Amir Harati, AlexMercer
// @match        https://claude.easychat.top/*
// @match        https://pro.easychat.top/*
// @match        https://claude.ai/*
// @match        https://chatgpt.com/*
// @match        https://chat.openai.com/*
// @match        https://gemini.google.com/app/*
// @match        https://notebooklm.google.com/*
// @match        https://aistudio.google.com/*
// @include      *://gemini.google.com/*
// @include      *://notebooklm.google.com/*
// @include      *://aistudio.google.com/*
// @run-at       document-start
// @grant        GM_addStyle
// @grant        GM_xmlhttpRequest
// @require      https://cdn.jsdelivr.net/npm/fflate@0.7.4/umd/index.js
// @license      GNU General Public License v3.0
// @downloadURL https://update.greasyfork.org/scripts/539579/Lyra%20Exporter%20Fetch.user.js
// @updateURL https://update.greasyfork.org/scripts/539579/Lyra%20Exporter%20Fetch.meta.js
// ==/UserScript==

    (function() {
        'use strict';
        if (window.lyraFetchInitialized) return;
        window.lyraFetchInitialized = true;

        // Trusted Types support for CSP compatibility
        let trustedPolicy = null;
        if (typeof window.trustedTypes !== 'undefined' && window.trustedTypes.createPolicy) {
            try {
                trustedPolicy = window.trustedTypes.createPolicy('lyra-exporter-policy', {
                    createHTML: (input) => input
                });
                console.log('[Lyra] Trusted-Types policy created successfully');
            } catch (e) {
                console.warn('[Lyra] Failed to create Trusted-Types policy:', e);
            }
        }

        function safeSetInnerHTML(element, html) {
            if (!element) return;
            if (trustedPolicy) {
                element.innerHTML = trustedPolicy.createHTML(html);
            } else {
                element.innerHTML = html;
            }
        }

        const Config = {
            CONTROL_ID: 'lyra-controls',
            TOGGLE_ID: 'lyra-toggle-button',
            LANG_SWITCH_ID: 'lyra-lang-switch',
            TREE_SWITCH_ID: 'lyra-tree-mode-switch',
            IMAGE_SWITCH_ID: 'lyra-image-switch',
            CANVAS_SWITCH_ID: 'lyra-canvas-switch',
            WORKSPACE_TYPE_ID: 'lyra-workspace-type',
            MANUAL_ID_BTN: 'lyra-manual-id-btn',
            EXPORTER_URL: 'https://yalums.github.io/lyra-exporter/',
            EXPORTER_ORIGIN: 'https://yalums.github.io',
            TIMING: {
                SCROLL_DELAY: 250,
                SCROLL_TOP_WAIT: 1000,
                VERSION_STABLE: 1500,
                VERSION_SCAN_INTERVAL: 1000,
                HREF_CHECK_INTERVAL: 800,
                PANEL_INIT_DELAY: 2000,
                BATCH_EXPORT_SLEEP: 300,
                BATCH_EXPORT_YIELD: 0
            }
        };

        const State = {
            currentPlatform: (() => {
                const host = window.location.hostname;
                console.log('[Lyra] Detecting platform, hostname:', host);
                if (host.includes('claude.ai') || host.endsWith('easychat.top') || host.includes('.easychat.top')) {
                    console.log('[Lyra] Platform detected: claude');
                    return 'claude';
                }
                if (host.includes('chatgpt') || host.includes('openai')) {
                    console.log('[Lyra] Platform detected: chatgpt');
                    return 'chatgpt';
                }
                if (host.includes('gemini')) {
                    console.log('[Lyra] Platform detected: gemini');
                    return 'gemini';
                }
                if (host.includes('notebooklm')) {
                    console.log('[Lyra] Platform detected: notebooklm');
                    return 'notebooklm';
                }
                if (host.includes('aistudio')) {
                    console.log('[Lyra] Platform detected: aistudio');
                    return 'aistudio';
                }
                console.log('[Lyra] Platform detected: null (unknown)');
                return null;
            })(),
            isPanelCollapsed: localStorage.getItem('lyraExporterCollapsed') === 'true',
            includeImages: localStorage.getItem('lyraIncludeImages') === 'true',
            capturedUserId: localStorage.getItem('lyraClaudeUserId') || '',
            chatgptAccessToken: null,
            chatgptUserId: localStorage.getItem('lyraChatGPTUserId') || '',
            chatgptWorkspaceId: localStorage.getItem('lyraChatGPTWorkspaceId') || '',
            chatgptWorkspaceType: localStorage.getItem('lyraChatGPTWorkspaceType') || 'user',
            panelInjected: false,
            includeCanvas: localStorage.getItem('lyraIncludeCanvas') === 'true'
        };

        let collectedData = new Map();
        const LyraFlags = {
            hasRetryWithoutToolButton: false,
            lastCanvasContent: null,
            lastCanvasMessageIndex: -1
        };

        const i18n = {
            languages: {
                zh: {
                    loading: '加载中...', exporting: '导出中...', compressing: '压缩中...', preparing: '准备中...',
                    exportSuccess: '导出成功!', noContent: '没有可导出的对话内容。',
                    exportCurrentJSON: '导出当前', exportAllConversations: '导出全部',
                    branchMode: '多分支', includeImages: '含图像',
                    enterFilename: '请输入文件名(不含扩展名):', untitledChat: '未命名对话',
                    uuidNotFound: '未找到对话UUID!', fetchFailed: '获取对话数据失败',
                    exportFailed: '导出失败: ', gettingConversation: '获取对话',
                    withImages: ' (处理图片中...)', successExported: '成功导出', conversations: '个对话!',
                    manualUserId: '手动设置ID', enterUserId: '请输入您的组织ID (settings/account):',
                    userIdSaved: '用户ID已保存!',
                    workspaceType: '团队空间', userWorkspace: '个人区', teamWorkspace: '工作区',
                    manualWorkspaceId: '手动设置工作区ID', enterWorkspaceId: '请输入工作区ID (工作空间设置/工作空间 ID):',
                    workspaceIdSaved: '工作区ID已保存!', tokenNotFound: '未找到访问令牌!',
                    viewOnline: '预览对话',
                    loadFailed: '加载失败: ',
                    cannotOpenExporter: '无法打开 Lyra Exporter,请检查弹窗拦截',
                    versionTracking: '实时',
                },
                en: {
                    loading: 'Loading...', exporting: 'Exporting...', compressing: 'Compressing...', preparing: 'Preparing...',
                    exportSuccess: 'Export successful!', noContent: 'No conversation content to export.',
                    exportCurrentJSON: 'Export', exportAllConversations: 'Save All',
                    branchMode: 'Branch', includeImages: 'Images',
                    enterFilename: 'Enter filename (without extension):', untitledChat: 'Untitled Chat',
                    uuidNotFound: 'UUID not found!', fetchFailed: 'Failed to fetch conversation data',
                    exportFailed: 'Export failed: ', gettingConversation: 'Getting conversation',
                    withImages: ' (processing images...)', successExported: 'Successfully exported', conversations: 'conversations!',
                    manualUserId: 'Customize UUID', enterUserId: 'Organization ID (settings/account)',
                    userIdSaved: 'User ID saved!',
                    workspaceType: 'Workspace', userWorkspace: 'Personal', teamWorkspace: 'Team',
                    manualWorkspaceId: 'Set Workspace ID', enterWorkspaceId: 'Enter Workspace ID(Workspace settings/Workspace ID):',
                    workspaceIdSaved: 'Workspace ID saved!', tokenNotFound: 'Access token not found!',
                    viewOnline: 'Preview',
                    loadFailed: 'Load failed: ',
                    cannotOpenExporter: 'Cannot open Lyra Exporter, please check popup blocker',
                    versionTracking: 'Realtime',
                }
            },
            currentLang: localStorage.getItem('lyraExporterLanguage') || (navigator.language.startsWith('zh') ? 'zh' : 'en'),
            t: (key) => i18n.languages[i18n.currentLang]?.[key] || key,
            setLanguage: (lang) => {
                i18n.currentLang = lang;
                localStorage.setItem('lyraExporterLanguage', lang);
            },
            getLanguageShort() {
                return this.currentLang === 'zh' ? '简体中文' : 'English';
            }
        };

        const previewIcon = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"></path><circle cx="12" cy="12" r="3"></circle></svg>';
        const collapseIcon = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"></polyline></svg>';
        const expandIcon = '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"></polyline></svg>';
        const exportIcon = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>';
        const zipIcon = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 11V9a7 7 0 0 0-7-7a7 7 0 0 0-7 7v2"></path><rect x="3" y="11" width="18" height="10" rx="2" ry="2"></rect></svg>';

        const ErrorHandler = {
            handle: (error, context, options = {}) => {
                const {
                    showAlert = true,
                    logToConsole = true,
                    userMessage = null
                } = options;

                const errorMsg = error?.message || String(error);
                const contextMsg = context ? `[${context}]` : '';

                if (logToConsole) {
                    console.error(`[Lyra] ${contextMsg}`, error);
                }

                if (showAlert) {
                    const displayMsg = userMessage || `${i18n.t('exportFailed')} ${errorMsg}`;
                    alert(displayMsg);
                }

                return false;
            }
        };

        const Utils = {
            sleep: (ms) => new Promise(resolve => setTimeout(resolve, ms)),

            sanitizeFilename: (name) => name.replace(/[^a-z0-9\u4e00-\u9fa5]/gi, '_').substring(0, 100),

            blobToBase64: (blob) => new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.onloadend = () => resolve(reader.result.split(',')[1]);
                reader.onerror = reject;
                reader.readAsDataURL(blob);
            }),

            downloadJSON: (jsonString, filename) => {
                const blob = new Blob([jsonString], { type: 'application/json' });
                Utils.downloadFile(blob, filename);
            },

            downloadFile: (blob, filename) => {
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = filename;
                a.click();
                URL.revokeObjectURL(url);
            },

            setButtonLoading: (btn, text) => {
                btn.disabled = true;
                safeSetInnerHTML(btn, `<div class="lyra-loading"></div> <span>${text}</span>`);
            },

            restoreButton: (btn, originalContent) => {
                btn.disabled = false;
                safeSetInnerHTML(btn, originalContent);
            },

            createButton: (innerHTML, onClick, useInlineStyles = false) => {
                const btn = document.createElement('button');
                btn.className = 'lyra-button';
                safeSetInnerHTML(btn, innerHTML);
                btn.addEventListener('click', () => onClick(btn));

                if (useInlineStyles) {
                    Object.assign(btn.style, {
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'flex-start',
                        gap: '8px',
                        width: '100%',
                        maxWidth: '100%',
                        padding: '8px 12px',
                        margin: '8px 0',
                        border: 'none',
                        borderRadius: '6px',
                        fontSize: '11px',
                        fontWeight: '500',
                        cursor: 'pointer',
                        letterSpacing: '0.3px',
                        height: '32px',
                        boxSizing: 'border-box',
                        whiteSpace: 'nowrap'
                    });
                }

                return btn;
            },

            createToggle: (label, id, checked = false) => {
                const container = document.createElement('div');
                container.className = 'lyra-toggle';
                const labelSpan = document.createElement('span');
                labelSpan.className = 'lyra-toggle-label';
                labelSpan.textContent = label;

                const switchLabel = document.createElement('label');
                switchLabel.className = 'lyra-switch';

                const input = document.createElement('input');
                input.type = 'checkbox';
                input.id = id;
                input.checked = checked;

                const slider = document.createElement('span');
                slider.className = 'lyra-slider';

                switchLabel.appendChild(input);
                switchLabel.appendChild(slider);
                container.appendChild(labelSpan);
                container.appendChild(switchLabel);

                return container;
            },

            createProgressElem: (parent) => {
                const elem = document.createElement('div');
                elem.className = 'lyra-progress';
                parent.appendChild(elem);
                return elem;
            }
        };

    // Simple hash function for better deduplication
    function simpleHash(str) {
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // Convert to 32bit integer
        }
        return hash.toString(36);
    }

    /**
     * Extract canvas content from a DOM element
     * Supports code blocks, artifacts, interactive elements, and text content
     * @param {Element} root - The root element to extract canvas from (typically a model-response container)
     * @returns {Array} Array of canvas objects with type, content, and metadata
     */
    function extractCanvasFromElement(root) {
        const canvasData = [];
        const seen = new Set();
        if (!root || !(root instanceof Element)) return canvasData;

        // Enhanced code block detection with multiple selectors
        const codeBlockSelectors = [
            'code-block',
            'pre code',
            '.code-block',
            '[data-code-block]',
            '.artifact-code',
            'code-execution-result code'
        ];

        codeBlockSelectors.forEach((selector) => {
            const blocks = root.querySelectorAll(selector);
            blocks.forEach((block) => {
                const codeContent = block.textContent || block.innerText;
                if (!codeContent) return;
                const trimmed = codeContent.trim();
                if (!trimmed || trimmed.length < 5) return; // Skip very short content

                const hash = simpleHash(trimmed);
                if (seen.has(hash)) return;
                seen.add(hash);

                // Try to detect language from multiple sources
                let language = 'unknown';
                const langAttr = block.querySelector('[data-lang]');
                if (langAttr) {
                    language = langAttr.getAttribute('data-lang') || 'unknown';
                } else if (block.className) {
                    const match = block.className.match(/language-(\w+)/);
                    if (match) language = match[1];
                }

                canvasData.push({
                    type: 'code',
                    content: trimmed,
                    language: language,
                    selector: selector
                });
            });
        });

        // Artifact detection (Gemini's interactive components)
        const artifactSelectors = [
            '[data-artifact]',
            '.artifact-container',
            'artifact-element',
            '.interactive-canvas'
        ];

        artifactSelectors.forEach((selector) => {
            const artifacts = root.querySelectorAll(selector);
            artifacts.forEach((artifact) => {
                const content = artifact.textContent || artifact.innerText;
                if (!content) return;
                const trimmed = content.trim();
                if (!trimmed || trimmed.length < 5) return;

                const hash = simpleHash(trimmed);
                if (seen.has(hash)) return;
                seen.add(hash);

                canvasData.push({
                    type: 'artifact',
                    content: trimmed,
                    selector: selector
                });
            });
        });

        // Canvas element detection (actual HTML5 canvas)
        const canvasElements = root.querySelectorAll('canvas');
        canvasElements.forEach((canvas) => {
            // Try to get canvas context or data
            const canvasId = canvas.id || canvas.className || 'unnamed-canvas';
            const hash = simpleHash(canvasId + canvas.width + canvas.height);
            if (seen.has(hash)) return;
            seen.add(hash);

            canvasData.push({
                type: 'canvas_element',
                content: `Canvas element: ${canvasId} (${canvas.width}x${canvas.height})`,
                metadata: {
                    id: canvasId,
                    width: canvas.width,
                    height: canvas.height
                }
            });
        });

        return canvasData;
    }

    function extractGlobalCanvasContent() {
        const canvasData = [];
        const seen = new Set();

        let globalRetryLabel = '';
        try {
            const retryBtnGlobal = document.querySelector('button.retry-without-tool-button');
            if (retryBtnGlobal) {
                globalRetryLabel = (retryBtnGlobal.innerText || '').trim();
            }
        } catch (e) {
            globalRetryLabel = '';
        }

        const codeBlocks = document.querySelectorAll('code-block, pre code, .code-block');
        codeBlocks.forEach((block) => {
            const codeContent = block.textContent || block.innerText;
            if (!codeContent) return;
            const trimmed = codeContent.trim();
            if (!trimmed) return;
            const key = trimmed.substring(0, 100);
            if (seen.has(key)) return;
            seen.add(key);

            const langAttr = block.querySelector('[data-lang]');
            const language = langAttr ? langAttr.getAttribute('data-lang') || 'unknown' : 'unknown';
            canvasData.push({
                type: 'code',
                content: trimmed,
                language: language
            });
        });

        const responseElements = document.querySelectorAll('response-element, .model-response-text, .markdown');
        responseElements.forEach((element) => {
            if (element.closest('code-block') || element.querySelector('code-block')) return;
            let clone;
            try {
                clone = element.cloneNode(true);
                clone.querySelectorAll('button.retry-without-tool-button').forEach(btn => btn.remove());
            } catch (e) {
                clone = element;
            }
            let md = '';
            try {
                md = htmlToMarkdown(clone).trim();
            } catch (e) {
                const textContent = element.textContent || element.innerText;
                md = textContent ? textContent.trim() : '';
            }
            if (!md) return;
            const key = md.substring(0, 100);
            if (seen.has(key)) return;
            seen.add(key);
            canvasData.push({
                type: 'text',
                content: md
            });
        });

        return canvasData;
    }
        const LyraCommunicator = {
            open: async (jsonData, filename) => {
                try {
                    const exporterWindow = window.open(Config.EXPORTER_URL, '_blank');
                    if (!exporterWindow) {
                        alert(i18n.t('cannotOpenExporter'));
                        return false;
                    }

                    const checkInterval = setInterval(() => {
                        try {
                            exporterWindow.postMessage({
                                type: 'LYRA_HANDSHAKE',
                                source: 'lyra-fetch-script'
                            }, Config.EXPORTER_ORIGIN);
                        } catch (e) {
                        }
                    }, 1000);

                    const handleMessage = (event) => {
                        if (event.origin !== Config.EXPORTER_ORIGIN) {
                            return;
                        }
                        if (event.data && event.data.type === 'LYRA_READY') {
                            clearInterval(checkInterval);
                            const dataToSend = {
                                type: 'LYRA_LOAD_DATA',
                                source: 'lyra-fetch-script',
                                data: {
                                    content: jsonData,
                                    filename: filename || `${State.currentPlatform}_export_${new Date().toISOString().slice(0,10)}.json`
                                }
                            };
                            exporterWindow.postMessage(dataToSend, Config.EXPORTER_ORIGIN);
                            window.removeEventListener('message', handleMessage);
                        }
                    };

                    window.addEventListener('message', handleMessage);

                    setTimeout(() => {
                        clearInterval(checkInterval);
                        window.removeEventListener('message', handleMessage);
                    }, 60000);

                    return true;
                } catch (error) {
                    alert(`${i18n.t('cannotOpenExporter')}: ${error.message}`);
                    return false;
                }
            }
        };

        const ClaudeHandler = {
        init: () => {
            const script = document.createElement('script');
            script.textContent = `
                (function() {
                    function captureUserId(url) {
                        const match = url.match(/\\/api\\/organizations\\/([a-f0-9-]+)\\//);
                        if (match && match[1]) {
                            localStorage.setItem('lyraClaudeUserId', match[1]);
                            window.dispatchEvent(new CustomEvent('lyraUserIdCaptured', { detail: { userId: match[1] } }));
                        }
                    }
                    const originalXHROpen = XMLHttpRequest.prototype.open;
                    XMLHttpRequest.prototype.open = function() {
                        if (arguments[1]) captureUserId(arguments[1]);
                        return originalXHROpen.apply(this, arguments);
                    };
                    const originalFetch = window.fetch;
                    window.fetch = function(resource) {
                        const url = typeof resource === 'string' ? resource : (resource.url || '');
                        if (url) captureUserId(url);
                        return originalFetch.apply(this, arguments);
                    };
                })();
            `;
            (document.head || document.documentElement).appendChild(script);
            script.remove();
            window.addEventListener('lyraUserIdCaptured', (e) => {
                if (e.detail.userId) State.capturedUserId = e.detail.userId;
            });
        },
        addUI: (controlsArea) => {

            const treeMode = window.location.search.includes('tree=true');
            controlsArea.appendChild(Utils.createToggle(i18n.t('branchMode'), Config.TREE_SWITCH_ID, treeMode));

            controlsArea.appendChild(Utils.createToggle(i18n.t('includeImages'), Config.IMAGE_SWITCH_ID, State.includeImages));
            document.addEventListener('change', (e) => {
                if (e.target.id === Config.IMAGE_SWITCH_ID) {
                    State.includeImages = e.target.checked;
                    localStorage.setItem('lyraIncludeImages', State.includeImages);
                }
            });
        },
        addButtons: (controlsArea) => {
            controlsArea.appendChild(Utils.createButton(
                `${previewIcon} ${i18n.t('viewOnline')}`,
                async (btn) => {
                    const uuid = ClaudeHandler.getCurrentUUID();
                    if (!uuid) { alert(i18n.t('uuidNotFound')); return; }
                    if (!await ClaudeHandler.ensureUserId()) return;
                    const original = btn.innerHTML;
                    Utils.setButtonLoading(btn, i18n.t('loading'));
                    try {
                        const includeImages = document.getElementById(Config.IMAGE_SWITCH_ID)?.checked || false;
                        const data = await ClaudeHandler.getConversation(uuid, includeImages);
                        if (!data) throw new Error(i18n.t('fetchFailed'));
                        const jsonString = JSON.stringify(data, null, 2);
                        const filename = `claude_${data.name || 'conversation'}_${uuid.substring(0, 8)}.json`;
                        await LyraCommunicator.open(jsonString, filename);
                    } catch (error) {
                        ErrorHandler.handle(error, 'Preview conversation', {
                            userMessage: `${i18n.t('loadFailed')} ${error.message}`
                        });
                    } finally {
                        Utils.restoreButton(btn, original);
                    }
                }
            ));
            controlsArea.appendChild(Utils.createButton(
                `${exportIcon} ${i18n.t('exportCurrentJSON')}`,
                async (btn) => {
                    const uuid = ClaudeHandler.getCurrentUUID();
                    if (!uuid) { alert(i18n.t('uuidNotFound')); return; }
                    if (!await ClaudeHandler.ensureUserId()) return;
                    const filename = prompt(i18n.t('enterFilename'), Utils.sanitizeFilename(`claude_${uuid.substring(0, 8)}`));
                    if (!filename?.trim()) return;
                    const original = btn.innerHTML;
                    Utils.setButtonLoading(btn, i18n.t('exporting'));
                    try {
                        const includeImages = document.getElementById(Config.IMAGE_SWITCH_ID)?.checked || false;
                        const data = await ClaudeHandler.getConversation(uuid, includeImages);
                        if (!data) throw new Error(i18n.t('fetchFailed'));
                        Utils.downloadJSON(JSON.stringify(data, null, 2), `${filename.trim()}.json`);
                    } catch (error) {
                        ErrorHandler.handle(error, 'Export conversation');
                    } finally {
                        Utils.restoreButton(btn, original);
                    }
                }
            ));
            controlsArea.appendChild(Utils.createButton(
                `${zipIcon} ${i18n.t('exportAllConversations')}`,
                (btn) => ClaudeHandler.exportAll(btn, controlsArea)
            ));
        },
        getCurrentUUID: () => window.location.pathname.match(/\/chat\/([a-zA-Z0-9-]+)/)?.[1],
        ensureUserId: async () => {
            if (State.capturedUserId) return State.capturedUserId;
            const saved = localStorage.getItem('lyraClaudeUserId');
            if (saved) {
                State.capturedUserId = saved;
                return saved;
            }
            alert('未能检测到用户ID / User ID not detected');
            return null;
        },
        getBaseUrl: () => {
            if (window.location.hostname.includes('claude.ai')) {
                return 'https://claude.ai';
            } else if (window.location.hostname.includes('easychat.top')) {
                return `https://${window.location.hostname}`;
            }
            return window.location.origin;
        },
        getAllConversations: async () => {
            const userId = await ClaudeHandler.ensureUserId();
            if (!userId) return null;
            try {
                const response = await fetch(`${ClaudeHandler.getBaseUrl()}/api/organizations/${userId}/chat_conversations`);
                if (!response.ok) throw new Error('Fetch failed');
                return await response.json();
            } catch (error) {
                console.error('Get all conversations error:', error);
                return null;
            }
        },
        getConversation: async (uuid, includeImages = false) => {
            const userId = await ClaudeHandler.ensureUserId();
            if (!userId) return null;
            try {
                const treeMode = document.getElementById(Config.TREE_SWITCH_ID)?.checked || false;
                const endpoint = treeMode ?
                    `/api/organizations/${userId}/chat_conversations/${uuid}?tree=True&rendering_mode=messages&render_all_tools=true` :
                    `/api/organizations/${userId}/chat_conversations/${uuid}`;
                const apiUrl = `${ClaudeHandler.getBaseUrl()}${endpoint}`;
                const response = await fetch(apiUrl);
                if (!response.ok) throw new Error(`Fetch failed: ${response.status}`);
                const data = await response.json();
                if (includeImages && data.chat_messages) {
                    for (const msg of data.chat_messages) {
                        const fileArrays = ['files', 'files_v2', 'attachments'];
                        for (const key of fileArrays) {
                            if (Array.isArray(msg[key])) {
                                for (const file of msg[key]) {
                                    const isImage = file.file_kind === 'image' || file.file_type?.startsWith('image/');
                                    const imageUrl = file.preview_url || file.thumbnail_url || file.file_url;
                                    if (isImage && imageUrl && !file.embedded_image) {
                                        try {
                                            const fullUrl = imageUrl.startsWith('http') ? imageUrl : ClaudeHandler.getBaseUrl() + imageUrl;
                                            const imgResp = await fetch(fullUrl);
                                            if (imgResp.ok) {
                                                const blob = await imgResp.blob();
                                                const base64 = await Utils.blobToBase64(blob);
                                                file.embedded_image = { type: 'image', format: blob.type, size: blob.size, data: base64, original_url: imageUrl };
                                            }
                                        } catch (err) {
                                            console.error('Process image error:', err);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                return data;
            } catch (error) {
                console.error('Get conversation error:', error);
                return null;
            }
        },
        exportAll: async (btn, controlsArea) => {
            if (typeof fflate === 'undefined' || typeof fflate.zipSync !== 'function' || typeof fflate.strToU8 !== 'function') {
                const errorMsg = i18n.currentLang === 'zh'
                    ? '批量导出功能需要压缩库支持。\n\n由于当前平台的安全策略限制,该功能暂时不可用。\n建议使用"导出当前"功能单个导出对话。'
                    : 'Batch export requires compression library.\n\nThis feature is currently unavailable due to platform security policies.\nPlease use "Export" button to export conversations individually.';
                alert(errorMsg);
                return;
            }
            if (!await ClaudeHandler.ensureUserId()) return;
            const progress = Utils.createProgressElem(controlsArea);
            progress.textContent = i18n.t('preparing');
            const original = btn.innerHTML;
            Utils.setButtonLoading(btn, i18n.t('exporting'));
            try {
                const allConvs = await ClaudeHandler.getAllConversations();
                if (!allConvs || !Array.isArray(allConvs)) throw new Error(i18n.t('fetchFailed'));
                const includeImages = document.getElementById(Config.IMAGE_SWITCH_ID)?.checked || false;
                let exported = 0;
                console.log(`Starting export of ${allConvs.length} conversations`);

                const zipEntries = {};
                for (let i = 0; i < allConvs.length; i++) {
                    const conv = allConvs[i];
                    progress.textContent = `${i18n.t('gettingConversation')} ${i + 1}/${allConvs.length}${includeImages ? i18n.t('withImages') : ''}`;
                    if (i > 0 && i % 5 === 0) {
                        await new Promise(resolve => setTimeout(resolve, Config.TIMING.BATCH_EXPORT_YIELD));
                    } else if (i > 0) {
                        await Utils.sleep(Config.TIMING.BATCH_EXPORT_SLEEP);
                    }
                    try {
                        const data = await ClaudeHandler.getConversation(conv.uuid, includeImages);
                        if (data) {
                            const title = Utils.sanitizeFilename(data.name || conv.uuid);
                            const filename = `claude_${conv.uuid.substring(0, 8)}_${title}.json`;
                            zipEntries[filename] = fflate.strToU8(JSON.stringify(data, null, 2));
                            exported++;
                        }
                    } catch (error) {
                        console.error(`Failed to process ${conv.uuid}:`, error);
                    }
                }
                console.log(`Export complete: ${exported} files. Compressing...`);
                progress.textContent = `${i18n.t('compressing')}…`;

                const zipUint8 = fflate.zipSync(zipEntries, { level: 1 });
                const zipBlob = new Blob([zipUint8], { type: 'application/zip' });

                const zipFilename = `claude_export_all_${new Date().toISOString().slice(0, 10)}.zip`;
                Utils.downloadFile(zipBlob, zipFilename);
                alert(`${i18n.t('successExported')} ${exported} ${i18n.t('conversations')}`);
            } catch (error) {
                ErrorHandler.handle(error, 'Export all conversations');
            } finally {
                Utils.restoreButton(btn, original);
                if (progress.parentNode) progress.parentNode.removeChild(progress);
            }
        }
    };

    const ChatGPTHandler = {
        init: () => {
            const rawFetch = window.fetch;
            window.fetch = async function(resource, options) {
                const headers = options?.headers;
                if (headers) {
                    let authHeader = null;
                    if (typeof headers === 'string') {
                        authHeader = headers;
                    } else if (headers instanceof Headers) {
                        authHeader = headers.get('Authorization');
                    } else {
                        authHeader = headers.Authorization || headers.authorization;
                    }

                    if (authHeader?.startsWith('Bearer ')) {
                        const token = authHeader.slice(7);
                        if (token && token.toLowerCase() !== 'dummy') {
                            State.chatgptAccessToken = token;
                        }
                    }
                }

                return rawFetch.apply(this, arguments);
            };
        },

        ensureAccessToken: async () => {
            if (State.chatgptAccessToken) return State.chatgptAccessToken;

            try {
                const response = await fetch('/api/auth/session?unstable_client=true');
                const session = await response.json();
                if (session.accessToken) {
                    State.chatgptAccessToken = session.accessToken;
                    return session.accessToken;
                }
            } catch (error) {
                console.error('Failed to get access token:', error);
            }

            return null;
        },

        getOaiDeviceId: () => {
            const cookieString = document.cookie;
            const match = cookieString.match(/oai-did=([^;]+)/);
            return match ? match[1] : null;
        },

        getCurrentConversationId: () => {
            const match = window.location.pathname.match(/\/c\/([a-zA-Z0-9-]+)/);
            return match ? match[1] : null;
        },

        getAllConversations: async () => {
            const token = await ChatGPTHandler.ensureAccessToken();
            if (!token) throw new Error(i18n.t('tokenNotFound'));

            const deviceId = ChatGPTHandler.getOaiDeviceId();
            if (!deviceId) throw new Error('Cannot get device ID');

            const headers = {
                'Authorization': `Bearer ${token}`,
                'oai-device-id': deviceId
            };

            if (State.chatgptWorkspaceType === 'team' && State.chatgptWorkspaceId) {
                headers['ChatGPT-Account-Id'] = State.chatgptWorkspaceId;
            }

            const allConversations = [];
            let offset = 0;
            let hasMore = true;

            while (hasMore) {
                const response = await fetch(`/backend-api/conversations?offset=${offset}&limit=28&order=updated`, { headers });
                if (!response.ok) throw new Error('Failed to fetch conversation list');

                const data = await response.json();
                if (data.items && data.items.length > 0) {
                    allConversations.push(...data.items);
                    hasMore = data.items.length === 28;
                    offset += data.items.length;
                } else {
                    hasMore = false;
                }
            }

            return allConversations;
        },

        getConversation: async (conversationId) => {
            const token = await ChatGPTHandler.ensureAccessToken();
            if (!token) {
                console.error('[ChatGPT] Token not found');
                throw new Error(i18n.t('tokenNotFound'));
            }

            const deviceId = ChatGPTHandler.getOaiDeviceId();
            if (!deviceId) {
                console.error('[ChatGPT] Device ID not found in cookies');
                throw new Error('Cannot get device ID');
            }

            const headers = {
                'Authorization': `Bearer ${token}`,
                'oai-device-id': deviceId
            };

            if (State.chatgptWorkspaceType === 'team' && State.chatgptWorkspaceId) {
                headers['ChatGPT-Account-Id'] = State.chatgptWorkspaceId;
            }

            console.log('[ChatGPT] Fetching conversation:', {
                conversationId,
                workspaceType: State.chatgptWorkspaceType,
                workspaceId: State.chatgptWorkspaceId,
                userId: State.chatgptUserId,
                willAddWorkspaceHeader: State.chatgptWorkspaceType === 'team' && !!State.chatgptWorkspaceId,
                hasToken: !!token,
                hasDeviceId: !!deviceId,
                tokenPrefix: token.substring(0, 10) + '...',
                headers: { ...headers, 'Authorization': 'Bearer ***' }
            });

            const response = await fetch(`/backend-api/conversation/${conversationId}`, { headers });

            console.log('[ChatGPT] Response status:', response.status);

            if (!response.ok) {
                const errorText = await response.text();
                console.error('[ChatGPT] Fetch failed:', {
                    status: response.status,
                    statusText: response.statusText,
                    error: errorText,
                    conversationId,
                    workspaceType: State.chatgptWorkspaceType
                });

                let errorMessage = `Failed to fetch conversation (${response.status}): ${errorText || response.statusText}`;
                if (response.status === 404) {
                    const currentMode = State.chatgptWorkspaceType === 'team' ? i18n.t('teamWorkspace') : i18n.t('userWorkspace');
                    const suggestMode = State.chatgptWorkspaceType === 'team' ? i18n.t('userWorkspace') : i18n.t('teamWorkspace');
                    errorMessage += `\n\n当前模式: ${currentMode}\n建议尝试切换到: ${suggestMode}`;
                    if (State.chatgptWorkspaceType === 'team') {
                        errorMessage += '并手动填写工作区ID';
                    } else {
                        errorMessage += '并手动填写个人ID';
                    }
                }

                throw new Error(errorMessage);
            }

            return await response.json();
        },

        previewConversation: async () => {
            const conversationId = ChatGPTHandler.getCurrentConversationId();
            if (!conversationId) {
                alert(i18n.t('uuidNotFound'));
                return;
            }

            try {
                const data = await ChatGPTHandler.getConversation(conversationId);
                const jsonString = JSON.stringify(data, null, 2);
                const filename = `chatgpt_${data.title || 'conversation'}_${conversationId.substring(0, 8)}.json`;
                await LyraCommunicator.open(jsonString, filename);
            } catch (error) {
                ErrorHandler.handle(error, 'Preview conversation', {
                    userMessage: `${i18n.t('loadFailed')} ${error.message}`
                });
            }
        },

        exportCurrent: async (btn) => {
            const conversationId = ChatGPTHandler.getCurrentConversationId();
            if (!conversationId) {
                alert(i18n.t('uuidNotFound'));
                return;
            }

            const original = btn.innerHTML;
            Utils.setButtonLoading(btn, i18n.t('exporting'));

            try {
                const data = await ChatGPTHandler.getConversation(conversationId);

                const filename = prompt(i18n.t('enterFilename'), data.title || i18n.t('untitledChat'));
                if (!filename) {
                    Utils.restoreButton(btn, original);
                    return;
                }

                Utils.downloadJSON(JSON.stringify(data, null, 2), `${Utils.sanitizeFilename(filename)}.json`);
            } catch (error) {
                ErrorHandler.handle(error, 'Export conversation');
            } finally {
                Utils.restoreButton(btn, original);
            }
        },

        exportAll: async (btn, controlsArea) => {
            if (typeof fflate === 'undefined' || typeof fflate.zipSync !== 'function' || typeof fflate.strToU8 !== 'function') {
                const errorMsg = i18n.currentLang === 'zh'
                    ? '批量导出功能需要压缩库支持。\n\n由于当前平台的安全策略限制,该功能暂时不可用。\n建议使用"导出当前"功能单个导出对话。'
                    : 'Batch export requires compression library.\n\nThis feature is currently unavailable due to platform security policies.\nPlease use "Export" button to export conversations individually.';
                alert(errorMsg);
                return;
            }

            const progress = Utils.createProgressElem(controlsArea);
            progress.textContent = i18n.t('preparing');
            const original = btn.innerHTML;
            Utils.setButtonLoading(btn, i18n.t('exporting'));

            try {
                const allConvs = await ChatGPTHandler.getAllConversations();
                if (!allConvs || !Array.isArray(allConvs)) throw new Error(i18n.t('fetchFailed'));

                let exported = 0;
                const zipEntries = {};

                for (let i = 0; i < allConvs.length; i++) {
                    const conv = allConvs[i];
                    progress.textContent = `${i18n.t('gettingConversation')} ${i + 1}/${allConvs.length}`;

                    if (i > 0 && i % 5 === 0) {
                        await new Promise(resolve => setTimeout(resolve, Config.TIMING.BATCH_EXPORT_YIELD));
                    } else if (i > 0) {
                        await Utils.sleep(Config.TIMING.BATCH_EXPORT_SLEEP);
                    }

                    try {
                        const data = await ChatGPTHandler.getConversation(conv.id);
                        if (data) {
                            const title = Utils.sanitizeFilename(data.title || conv.id);
                            const filename = `chatgpt_${conv.id.substring(0, 8)}_${title}.json`;
                            zipEntries[filename] = fflate.strToU8(JSON.stringify(data, null, 2));
                            exported++;
                        }
                    } catch (error) {
                        console.error(`Failed to process ${conv.id}:`, error);
                    }
                }

                progress.textContent = `${i18n.t('compressing')}…`;
                const zipUint8 = fflate.zipSync(zipEntries, { level: 1 });
                const zipBlob = new Blob([zipUint8], { type: 'application/zip' });

                const zipFilename = `chatgpt_export_all_${new Date().toISOString().slice(0, 10)}.zip`;
                Utils.downloadFile(zipBlob, zipFilename);
                alert(`${i18n.t('successExported')} ${exported} ${i18n.t('conversations')}`);
            } catch (error) {
                ErrorHandler.handle(error, 'Export all conversations');
            } finally {
                Utils.restoreButton(btn, original);
                if (progress.parentNode) progress.parentNode.removeChild(progress);
            }
        },

        addUI: (controls) => {
            const initialLabel = State.chatgptWorkspaceType === 'team' ? i18n.t('teamWorkspace') : i18n.t('userWorkspace');
            const workspaceToggle = Utils.createToggle(
                initialLabel,
                Config.WORKSPACE_TYPE_ID,
                State.chatgptWorkspaceType === 'team'
            );

            const toggleInput = workspaceToggle.querySelector('input');
            const toggleLabel = workspaceToggle.querySelector('.lyra-toggle-label');

            toggleInput.addEventListener('change', (e) => {
                State.chatgptWorkspaceType = e.target.checked ? 'team' : 'user';
                localStorage.setItem('lyraChatGPTWorkspaceType', State.chatgptWorkspaceType);
                toggleLabel.textContent = e.target.checked ? i18n.t('teamWorkspace') : i18n.t('userWorkspace');
                console.log('[ChatGPT] Workspace type changed to:', State.chatgptWorkspaceType);
                UI.recreatePanel();
            });

            controls.appendChild(workspaceToggle);
        },

        addButtons: (controls) => {
            controls.appendChild(Utils.createButton(
                `${previewIcon} ${i18n.t('viewOnline')}`,
                () => ChatGPTHandler.previewConversation()
            ));

            controls.appendChild(Utils.createButton(
                `${exportIcon} ${i18n.t('exportCurrentJSON')}`,
                (btn) => ChatGPTHandler.exportCurrent(btn)
            ));

            controls.appendChild(Utils.createButton(
                `${zipIcon} ${i18n.t('exportAllConversations')}`,
                (btn) => ChatGPTHandler.exportAll(btn, controls)
            ));

            const idLabel = document.createElement('div');
            idLabel.className = 'lyra-input-trigger';

            if (State.chatgptWorkspaceType === 'user') {
                idLabel.textContent = `${i18n.t('manualUserId')}`;
                idLabel.addEventListener('click', () => {
                    const newId = prompt(i18n.t('enterUserId'));
                    if (newId?.trim()) {
                        State.chatgptUserId = newId.trim();
                        localStorage.setItem('lyraChatGPTUserId', State.chatgptUserId);
                        alert(i18n.t('userIdSaved'));
                    }
                });
            } else {
                idLabel.textContent = `${i18n.t('manualWorkspaceId')}`;
                idLabel.addEventListener('click', () => {
                    const newId = prompt(i18n.t('enterWorkspaceId'));
                    if (newId?.trim()) {
                        State.chatgptWorkspaceId = newId.trim();
                        localStorage.setItem('lyraChatGPTWorkspaceId', State.chatgptWorkspaceId);
                        alert(i18n.t('workspaceIdSaved'));
                    }
                });
            }

            controls.appendChild(idLabel);
        }
    };

        // Version tracking system for Gemini (from new file)
        const VersionTracker = {
            tracker: null,
            scanInterval: null,
            hrefCheckInterval: null,
            currentHref: location.href,
            isTracking: false,

            createEmptyTracker: () => {
                return { turns: {}, order: [] };
            },

            resetTracker: (reason) => {
                VersionTracker.tracker = VersionTracker.createEmptyTracker();
                console.log('[LyraGemini] Version tracker reset:', reason || '');
            },

            startTracking: () => {
                if (VersionTracker.isTracking) return;
                VersionTracker.isTracking = true;
                VersionTracker.resetTracker('start tracking');

                // Start continuous scanning
                VersionTracker.scanInterval = setInterval(() => {
                    VersionTracker.scanOnce();
                }, Config.TIMING.VERSION_SCAN_INTERVAL);

                // Watch for URL changes
                VersionTracker.hrefCheckInterval = setInterval(() => {
                    if (location.href !== VersionTracker.currentHref) {
                        VersionTracker.currentHref = location.href;
                        VersionTracker.resetTracker('href changed');
                    }
                }, Config.TIMING.HREF_CHECK_INTERVAL);

                console.log('[LyraGemini] Version tracking started');
            },

            stopTracking: () => {
                if (!VersionTracker.isTracking) return;
                VersionTracker.isTracking = false;

                if (VersionTracker.scanInterval) {
                    clearInterval(VersionTracker.scanInterval);
                    VersionTracker.scanInterval = null;
                }

                if (VersionTracker.hrefCheckInterval) {
                    clearInterval(VersionTracker.hrefCheckInterval);
                    VersionTracker.hrefCheckInterval = null;
                }

                console.log('[LyraGemini] Version tracking stopped');
            },

            ensureTurn: (turnId) => {
                const tracker = VersionTracker.tracker;
                let t = tracker.turns[turnId];
                if (!t) {
                    t = {
                        id: turnId,
                        userVersions: [],
                        assistantVersions: [],
                        userLastText: '',
                        assistantCommittedText: '',
                        assistantPendingText: '',
                        assistantPendingSince: 0,
                        uvBest: {}
                    };
                    tracker.turns[turnId] = t;
                    tracker.order.push(turnId);
                }
                return t;
            },

            getTurnId: (node, idx) => {
                const attr = node.getAttribute &&
                    (node.getAttribute('data-message-id') || node.getAttribute('data-id'));
                return attr || `turn-${idx}`;
            },

            containsEither: (a, b) => {
                if (!a || !b) return false;
                const na = a.replace(/\s+/g, ' ').trim();
                const nb = b.replace(/\s+/g, ' ').trim();
                return na.includes(nb) || nb.includes(na);
            },

            handleUser: (turnId, text) => {
                const t = VersionTracker.ensureTurn(turnId);
                const value = (text || '').trim();
                if (!value) return;

                if (!t.userLastText) {
                    t.userLastText = value;
                    t.userVersions.push({ version: 0, type: 'normal', text: value });
                } else if (value !== t.userLastText) {
                    t.userLastText = value;
                    t.userVersions.push({ version: t.userVersions.length, type: 'edit', text: value });
                }
            },

            handleAssistant: (turnId, domText) => {
                const t = VersionTracker.ensureTurn(turnId);
                const text = (domText || '').trim();
                if (!text) return;

                const now = Date.now();

                if (text !== t.assistantPendingText) {
                    t.assistantPendingText = text;
                    t.assistantPendingSince = now;
                    return;
                }
                if (now - t.assistantPendingSince < Config.TIMING.VERSION_STABLE) return;

                let userVersionIndex = null;
                if (t.userVersions.length > 0) {
                    const lastUser = t.userVersions[t.userVersions.length - 1];
                    userVersionIndex = lastUser.version;
                }
                const uvKey = String(userVersionIndex);

                const best = t.uvBest[uvKey];
                if (!best || text.length < best.len) {
                    t.uvBest[uvKey] = { text, len: text.length };
                }

                const prevCommitted = t.assistantCommittedText || '';
                const isSameUVAsLastCommit = (t.assistantVersions.length > 0)
                    ? String(t.assistantVersions[t.assistantVersions.length - 1].userVersion) === uvKey
                    : true;

                const onlyVisibilityNoise = VersionTracker.containsEither(prevCommitted, text);
                const shouldCommit = (!onlyVisibilityNoise) || !isSameUVAsLastCommit;

                if (!shouldCommit) return;

                const version = t.assistantVersions.length;
                const type = version === 0 ? 'normal' : 'retry';

                t.assistantVersions.push({
                    version,
                    type,
                    userVersion: userVersionIndex,
                    text
                });

                t.assistantCommittedText = text;
            },

            scanOnce: () => {
                const turns = document.querySelectorAll(
                    'div.conversation-turn, div.single-turn, div.conversation-container'
                );
                if (!turns.length) return;

                turns.forEach((turn, idx) => {
                    const id = VersionTracker.getTurnId(turn, idx);
                    const userText = VersionTracker.getUserText(turn);
                    const assistantText = VersionTracker.getAssistantText(turn);
                    VersionTracker.handleUser(id, userText);
                    VersionTracker.handleAssistant(id, assistantText);
                });
            },

            getUserText: (turn) => {
                const el = turn.querySelector('user-query .query-text') ||
                    turn.querySelector('.query-text-line') ||
                    turn.querySelector('[data-user-text]') ||
                    null;
                return el ? el.innerText.trim() : '';
            },

            getAssistantText: (turn) => {
                const panel = turn.querySelector('model-response .markdown-main-panel') ||
                    turn.querySelector('.markdown-main-panel') ||
                    turn.querySelector('model-response') ||
                    turn.querySelector('.response-container') ||
                    null;
                if (!panel) return '';
                // Use htmlToMarkdown for consistent formatting with non-realtime mode
                const clone = panel.cloneNode(true);
                try {
                    clone.querySelectorAll('button.retry-without-tool-button').forEach(btn => btn.remove());
                } catch (e) {}
                return htmlToMarkdown(clone);
            },

            buildVersionedData: (title) => {
                // No need to scan here - continuous scanning is already running
                const tracker = VersionTracker.tracker;
                const result = [];

                tracker.order.forEach((id, index) => {
                    const t = tracker.turns[id];
                    if (!t) return;

                    const hasUser = t.userVersions.length > 0;
                    const hasAssistant = t.assistantVersions.length > 0;

                    result.push({
                        turnIndex: index,
                        human: hasUser ? {
                            versions: t.userVersions.map(v => ({
                                version: v.version,
                                type: v.type,
                                text: v.text
                            }))
                        } : null,
                        assistant: hasAssistant ? {
                            versions: t.assistantVersions.map(v => ({
                                version: v.version,
                                type: v.type,
                                userVersion: v.userVersion,
                                text: v.text
                            }))
                        } : null
                    });
                });

                return {
                    title: title || 'Gemini Chat',
                    platform: 'gemini',
                    exportedAt: new Date().toISOString(),
                    conversation: result
                };
            }
        };

        // Initialize version tracker (tracker will be reset when tracking starts)
        VersionTracker.tracker = VersionTracker.createEmptyTracker();

        // Global functions for debugging
        window.lyraGeminiExport = function (title) {
            const data = VersionTracker.buildVersionedData(title || 'Gemini Chat');
            console.log('[LyraGemini] export data:', data);
            return data;
        };
        window.lyraGeminiReset = function () {
            VersionTracker.resetTracker('manual reset');
        };

        function fetchViaGM(url) {
            return new Promise((resolve, reject) => {
                if (typeof GM_xmlhttpRequest === 'undefined') {
                    console.error('GM_xmlhttpRequest is not defined. Make sure @grant GM_xmlhttpRequest is in the script header.');
                    fetch(url).then(response => {
                        if (response.ok) return response.blob();
                        throw new Error(`Fetch failed with status: ${response.status}`);
                    }).then(resolve).catch(reject);
                    return;
                }

                GM_xmlhttpRequest({
                    method: "GET",
                    url: url,
                    responseType: "blob",
                    onload: function(response) {
                        if (response.status >= 200 && response.status < 300) {
                            resolve(response.response);
                        } else {
                            reject(new Error(`GM_xmlhttpRequest failed with status: ${response.status}`));
                        }
                    },
                    onerror: function(error) {
                        reject(new Error(`GM_xmlhttpRequest network error: ${error.statusText || 'Unknown error'}`));
                    }
                });
            });
        }

        async function processImageElement(imgElement) {
            if (!imgElement) return null;
            let imageUrlToFetch = null;

            const previewContainer = imgElement.closest('user-query-file-preview');
            if (previewContainer) {
                const lensLinkElement = previewContainer.querySelector('a[href*="lens.google.com"]');
                if (lensLinkElement && lensLinkElement.href) {
                    try {
                        const urlObject = new URL(lensLinkElement.href);
                        const realImageUrl = urlObject.searchParams.get('url');
                        if (realImageUrl) {
                            imageUrlToFetch = realImageUrl;
                        }
                    } catch (e) {
                        console.error('Error parsing Lens URL:', e);
                    }
                }
            }

            if (!imageUrlToFetch) {
                const fallbackSrc = imgElement.src;
                if (fallbackSrc && !fallbackSrc.startsWith('data:')) {
                    imageUrlToFetch = fallbackSrc;
                }
            }

            if (!imageUrlToFetch) {
                return null;
            }

            try {
                const blob = await fetchViaGM(imageUrlToFetch);
                const base64 = await Utils.blobToBase64(blob);
                return {
                    type: 'image',
                    format: blob.type,
                    size: blob.size,
                    data: base64,
                    original_src: imageUrlToFetch
                };
            } catch (error) {
                console.error('Failed to process image:', imageUrlToFetch, error);
                return null;
            }
        }

        function htmlToMarkdown(element) {
            if (!element) return '';
            let result = '';
            function processNode(node) {
                if (node.nodeType === Node.TEXT_NODE) {
                    return node.textContent;
                }
                if (node.nodeType !== Node.ELEMENT_NODE) {
                    return '';
                }
                const tagName = node.tagName.toLowerCase();
                const children = Array.from(node.childNodes).map(processNode).join('');
                switch(tagName) {
                    case 'h1': return `\n# ${children}\n`;
                    case 'h2': return `\n## ${children}\n`;
                    case 'h3': return `\n### ${children}\n`;
                    case 'h4': return `\n#### ${children}\n`;
                    case 'h5': return `\n##### ${children}\n`;
                    case 'h6': return `\n###### ${children}\n`;
                    case 'strong':
                    case 'b': return `**${children}**`;
                    case 'em':
                    case 'i': return `*${children}*`;
                    case 'code':
                        const parentIsPre = node.parentElement?.tagName.toLowerCase() === 'pre';
                        if (children.includes('\n') || parentIsPre) {
                            if (parentIsPre) return children;
                            return `\n\`\`\`\n${children}\n\`\`\`\n`;
                        }
                        return `\`${children}\``;
                    case 'pre':
                        const codeChild = node.querySelector('code');
                        if (codeChild) {
                            const lang = codeChild.className.match(/language-(\w+)/)?.[1] || '';
                            const codeContent = codeChild.textContent;
                            return `\n\`\`\`${lang}\n${codeContent}\n\`\`\`\n`;
                        }
                        return `\n\`\`\`\n${children}\n\`\`\`\n`;
                    case 'hr': return '\n---\n';
                    case 'br': return '\n';
                    case 'p': return `\n${children}\n`;
                    case 'div': return `${children}`;
                    case 'a':
                        const href = node.getAttribute('href');
                        if (href) {
                            return `[${children}](${href})`;
                        }
                        return children;
                    case 'ul':
                        return `\n${Array.from(node.children).map(li => `- ${processNode(li)}`).join('\n')}\n`;
                    case 'ol':
                        return `\n${Array.from(node.children).map((li, i) => `${i + 1}. ${processNode(li)}`).join('\n')}\n`;
                    case 'li':
                        return children;
                    case 'blockquote': return `\n> ${children.split('\n').join('\n> ')}\n`;
                    case 'table': return `\n${children}\n`;
                    case 'thead': return `${children}`;
                    case 'tbody': return `${children}`;
                    case 'tr': return `${children}|\n`;
                    case 'th': return `| **${children}** `;
                    case 'td': return `| ${children} `;
                    default: return children;
                }
            }
            result = processNode(element);
            result = result.replace(/^\s+/, '');
            result = result.replace(/\n{3,}/g, '\n\n');
            result = result.trim();
            return result;
        }
        function getAIStudioScroller() {
            const selectors = [
                'ms-chat-session ms-autoscroll-container',
                'mat-sidenav-content',
                '.chat-view-container'
            ];
            for (const selector of selectors) {
                const el = document.querySelector(selector);
                if (el && (el.scrollHeight > el.clientHeight || el.scrollWidth > el.clientWidth)) {
                    return el;
                }
            }
            return document.documentElement;
        }

        async function extractDataIncremental_AiStudio(includeImages = true) {
            const turns = document.querySelectorAll('ms-chat-turn');

            for (const turn of turns) {
                if (collectedData.has(turn)) { continue; }

                const isUserTurn = turn.querySelector('.chat-turn-container.user');
                const isModelTurn = turn.querySelector('.chat-turn-container.model');
                let turnData = { type: 'unknown', text: '', images: [] };

                if (isUserTurn) {
                    const userPromptNode = isUserTurn.querySelector('.user-prompt-container .turn-content');
                    if (userPromptNode) {
                        let userText = userPromptNode.innerText.trim();
                        if (userText.match(/^User\s*[\n:]?/i)) {
                        userText = userText.replace(/^User\s*[\n:]?/i, '').trim();
                        }
                        if (userText) {
                            turnData.type = 'user';
                            turnData.text = userText;
                        }
                    }
                    if (includeImages) {
                        const imgNodes = isUserTurn.querySelectorAll('.user-prompt-container img');
                        const imgPromises = Array.from(imgNodes).map(processImageElement);
                        turnData.images = (await Promise.all(imgPromises)).filter(Boolean);
                    }

                } else if (isModelTurn) {
                    const responseChunks = isModelTurn.querySelectorAll('ms-prompt-chunk');
                    let responseTexts = [];
                    const imgPromises = [];

                    responseChunks.forEach(chunk => {
                        if (!chunk.querySelector('ms-thought-chunk')) {
                            const cmarkNode = chunk.querySelector('ms-cmark-node');
                            if (cmarkNode) {
                                const markdownText = htmlToMarkdown(cmarkNode);
                                if (markdownText) {
                                    responseTexts.push(markdownText);
                                }
                                if (includeImages) {
                                    const imgNodes = cmarkNode.querySelectorAll('img');
                                    imgNodes.forEach(img => imgPromises.push(processImageElement(img)));
                                }
                            }
                        }
                    });
                    const responseText = responseTexts.join('\n\n').trim();
                    if (responseText) {
                        turnData.type = 'model';
                        turnData.text = responseText;
                    }
                    if (includeImages) {
                        turnData.images = (await Promise.all(imgPromises)).filter(Boolean);
                    }
                }

                if (turnData.type !== 'unknown' && (turnData.text || turnData.images.length > 0)) {
                    collectedData.set(turn, turnData);
                }
            }
        }
        const ScraperHandler = {
            handlers: {
                gemini: {
                    getTitle: () => {
                        const input = prompt('请输入对话标题 / Enter title:', '对话');
                        if (input === null) return null;
                        return input || i18n.t('untitledChat');
                    },
                    extractData: async (includeImages = true) => {
                        const conversationData = [];
                        const turns = document.querySelectorAll("div.conversation-turn, div.single-turn, div.conversation-container");

                        const processContainer = async (container) => {
                            const userQueryElement = container.querySelector("user-query .query-text") || container.querySelector(".query-text-line");
                            const modelResponseContainer = container.querySelector("model-response") || container;

                            const modelResponseElement = modelResponseContainer.querySelector("message-content .markdown-main-panel");

                            const humanText = userQueryElement ? userQueryElement.innerText.trim() : "";
                            let assistantText = "";

                            if (modelResponseElement) {
                                const clone = modelResponseElement.cloneNode(true);
                                try {
                                    clone.querySelectorAll('button.retry-without-tool-button').forEach(btn => btn.remove());
                                } catch (e) {
                                }
                                assistantText = htmlToMarkdown(clone);
                            } else {
                                const fallbackEl = modelResponseContainer.querySelector("model-response, .response-container");
                                if (fallbackEl) assistantText = fallbackEl.innerText.trim();
                            }

                            let userImages = [];
                            let modelImages = [];

                            if (includeImages) {
                                const userImageElements = container.querySelectorAll("user-query img");
                                const modelImageElements = modelResponseContainer.querySelectorAll("model-response img");

                                const userImagesPromises = Array.from(userImageElements).map(processImageElement);
                                const modelImagesPromises = Array.from(modelImageElements).map(processImageElement);

                                userImages = (await Promise.all(userImagesPromises)).filter(Boolean);
                                modelImages = (await Promise.all(modelImagesPromises)).filter(Boolean);
                            }

                            if (humanText || assistantText || userImages.length > 0 || modelImages.length > 0) {
                                const humanObj = { text: humanText };
                                if (userImages && userImages.length > 0) humanObj.images = userImages;

                                const assistantObj = { text: assistantText };
                                if (modelImages && modelImages.length > 0) assistantObj.images = modelImages;

                                conversationData.push({ human: humanObj, assistant: assistantObj });
                            }
                        };

                        for (const turn of turns) {
                            await processContainer(turn);
                        }

                        return conversationData;
                    }
                },
                notebooklm: {
                    getTitle: () => 'NotebookLM_' + new Date().toISOString().slice(0, 10),
                    extractData: async (includeImages = true) => {
                        const data = [];
                        const turns = document.querySelectorAll("div.chat-message-pair");

                        for (const turn of turns) {
                            let question = turn.querySelector("chat-message .from-user-container .message-text-content")?.innerText.trim() || "";
                            if (question.startsWith('[Preamble] ')) question = question.substring('[Preamble] '.length).trim();

                            let answer = "";
                            const answerEl = turn.querySelector("chat-message .to-user-container .message-text-content");
                            if (answerEl) {
                                const parts = [];
                                answerEl.querySelectorAll('labs-tailwind-structural-element-view-v2').forEach(el => {
                                    let line = el.querySelector('.bullet')?.innerText.trim() + ' ' || '';
                                    const para = el.querySelector('.paragraph');
                                    if (para) {
                                        let text = '';
                                        para.childNodes.forEach(node => {
                                            if (node.nodeType === Node.TEXT_NODE) text += node.textContent;
                                            else if (node.nodeType === Node.ELEMENT_NODE && !node.querySelector?.('.citation-marker')) {
                                                text += node.classList?.contains('bold') ? `**${node.innerText}**` : (node.innerText || node.textContent || '');
                                            }
                                        });
                                        line += text;
                                    }
                                    if (line.trim()) parts.push(line.trim());
                                });
                                answer = parts.join('\n\n');
                            }

                            let userImages = [];
                            let modelImages = [];

                            if (includeImages) {
                                const userImageElements = turn.querySelectorAll("chat-message .from-user-container img");
                                const modelImageElements = turn.querySelectorAll("chat-message .to-user-container img");

                                const userImagesPromises = Array.from(userImageElements).map(processImageElement);
                                const modelImagesPromises = Array.from(modelImageElements).map(processImageElement);

                                userImages = (await Promise.all(userImagesPromises)).filter(Boolean);
                                modelImages = (await Promise.all(modelImagesPromises)).filter(Boolean);
                            }

                            if (question || answer || userImages.length > 0 || modelImages.length > 0) {
                                const humanObj = { text: question };
                                if (userImages && userImages.length > 0) humanObj.images = userImages;
                                const assistantObj = { text: answer };
                                if (modelImages && modelImages.length > 0) assistantObj.images = modelImages;
                                data.push({ human: humanObj, assistant: assistantObj });
                            }
                        }
                        return data;
                    }
                },
                aistudio: {
                    getTitle: () => {
                        const input = prompt('请输入对话标题 / Enter title:', 'AI_Studio_Chat');
                        if (input === null) return null;
                        return input || 'AI_Studio_Chat';
                    },
                    extractData: async (includeImages = true) => {
                        collectedData.clear();
                        const scroller = getAIStudioScroller();
                        scroller.scrollTop = 0;
                        await Utils.sleep(Config.TIMING.SCROLL_TOP_WAIT);

                        let lastScrollTop = -1;

                        while (true) {
                            await extractDataIncremental_AiStudio(includeImages);

                            if (scroller.scrollTop + scroller.clientHeight >= scroller.scrollHeight - 10) {
                                break;
                            }

                            lastScrollTop = scroller.scrollTop;
                            scroller.scrollTop += scroller.clientHeight * 0.85;
                            await Utils.sleep(Config.TIMING.SCROLL_DELAY);

                            if (scroller.scrollTop === lastScrollTop) {
                                break;
                            }
                        }

                        await extractDataIncremental_AiStudio(includeImages);
                        await Utils.sleep(500);

                        const finalTurnsInDom = document.querySelectorAll('ms-chat-turn');
                        let sortedData = [];
                        finalTurnsInDom.forEach(turnNode => {
                            if (collectedData.has(turnNode)) {
                                sortedData.push(collectedData.get(turnNode));
                            }
                        });

                        const pairedData = [];
                        let lastHuman = null;
                        sortedData.forEach(item => {
                            if (item.type === 'user') {
                                if (!lastHuman) lastHuman = { text: '', images: [] };
                                lastHuman.text = (lastHuman.text ? lastHuman.text + '\n' : '') + item.text;
                                if (Array.isArray(item.images) && item.images.length > 0) {
                                    lastHuman.images.push(...item.images);
                                }
                            } else if (item.type === 'model' && lastHuman) {
                                const humanObj = { text: lastHuman.text };
                                if (Array.isArray(lastHuman.images) && lastHuman.images.length > 0) humanObj.images = lastHuman.images;
                                const assistantObj = { text: item.text };
                                if (Array.isArray(item.images) && item.images.length > 0) assistantObj.images = item.images;
                                pairedData.push({ human: humanObj, assistant: assistantObj });
                                lastHuman = null;
                            } else if (item.type === 'model' && !lastHuman) {
                                const humanObj = { text: "[No preceding user prompt found]" };
                                const assistantObj = { text: item.text };
                                if (Array.isArray(item.images) && item.images.length > 0) assistantObj.images = item.images;
                                pairedData.push({ human: humanObj, assistant: assistantObj });
                            }
                        });

                        if (lastHuman) {
                            const humanObj = { text: lastHuman.text };
                            if (Array.isArray(lastHuman.images) && lastHuman.images.length > 0) humanObj.images = lastHuman.images;
                            pairedData.push({ human: humanObj, assistant: { text: "[Model response is pending]" } });
                        }

                        return pairedData;
                    }
                }
            },

            // Helper function to build conversation JSON (eliminates code duplication)
            buildConversationJson: async (platform, title, progressElem = null) => {
                const handler = ScraperHandler.handlers[platform];
                if (!handler) throw new Error('Invalid platform handler');

                let finalJson;

                if (platform === 'gemini') {
                    const useVersionTracking = document.getElementById(Config.CANVAS_SWITCH_ID)?.checked || false;

                    if (useVersionTracking) {
                        // Use version tracking mode
                        finalJson = VersionTracker.buildVersionedData(title);
                    } else {
                        // Use normal mode with canvas content (automatically extracted per message)
                        const includeImages = document.getElementById(Config.IMAGE_SWITCH_ID)?.checked || false;
                        const conversationData = await handler.extractData(includeImages);

                        if (!conversationData || conversationData.length === 0) {
                            throw new Error(i18n.t('noContent'));
                        }

                        finalJson = {
                            title: title,
                            platform: platform,
                            exportedAt: new Date().toISOString(),
                            conversation: conversationData
                        };
                        // Canvas content is now automatically attached during extraction
                    }
                } else {
                    const includeImages = (platform === 'aistudio') ?
                        (document.getElementById(Config.IMAGE_SWITCH_ID)?.checked || false) : true;
                    const conversationData = await handler.extractData(includeImages);

                    if (!conversationData || conversationData.length === 0) {
                        throw new Error(i18n.t('noContent'));
                    }

                    finalJson = {
                        title: title,
                        platform: platform,
                        exportedAt: new Date().toISOString(),
                        conversation: conversationData
                    };
                }

                return finalJson;
            },

            addButtons: (controlsArea, platform) => {
            const handler = ScraperHandler.handlers[platform];
            if (!handler) return;

            if (platform === 'gemini') {
            const canvasToggle = Utils.createToggle(i18n.t('versionTracking') || '版本追踪', Config.CANVAS_SWITCH_ID, State.includeCanvas);
            controlsArea.appendChild(canvasToggle);

            const themeColor = '#1a73e8';
            const toggleSwitch = canvasToggle.querySelector('.lyra-switch input');
            if (toggleSwitch) {
            toggleSwitch.addEventListener('change', (e) => {
            State.includeCanvas = e.target.checked;
            localStorage.setItem('lyraIncludeCanvas', State.includeCanvas);
            console.log('[Canvas] Toggle changed:', State.includeCanvas);

            // Start or stop version tracking based on toggle state
            if (e.target.checked) {
                VersionTracker.startTracking();
            } else {
                VersionTracker.stopTracking();
            }
            });

            const slider = canvasToggle.querySelector('.lyra-slider');
            if (slider) {
            slider.style.setProperty('--theme-color', themeColor);
            }

            // Start tracking if toggle is already enabled
            if (State.includeCanvas) {
                VersionTracker.startTracking();
            }
            }
            }

            if (platform === 'gemini' || platform === 'aistudio') {
            const imageToggle = Utils.createToggle(i18n.t('includeImages'), Config.IMAGE_SWITCH_ID, State.includeImages);
            controlsArea.appendChild(imageToggle);

            const themeColors = { gemini: '#1a73e8', aistudio: '#777779' };
            const toggleSwitch = imageToggle.querySelector('.lyra-switch input');
            if (toggleSwitch) {
            toggleSwitch.addEventListener('change', (e) => {
            State.includeImages = e.target.checked;
            localStorage.setItem('lyraIncludeImages', State.includeImages);
            });

            const slider = imageToggle.querySelector('.lyra-slider');
            if (slider) {
            const color = themeColors[platform];
            slider.style.setProperty('--theme-color', color);
            }
            }
            }

            const useInlineStyles = (platform === 'notebooklm' || platform === 'gemini');
            const buttonColor = { gemini: '#1a73e8', notebooklm: '#000000', aistudio: '#777779' }[platform] || '#4285f4';

            // NotebookLM 只显示导出按钮，不显示预览按钮
            if (platform !== 'notebooklm') {
            const previewBtn = Utils.createButton(
                `${previewIcon} ${i18n.t('viewOnline')}`,
            async (btn) => {
                const title = handler.getTitle();
                        if (!title) return;

                const original = btn.innerHTML;
                        Utils.setButtonLoading(btn, i18n.t('loading'));

                let progressElem = null;
            if (platform === 'aistudio') {
                progressElem = Utils.createProgressElem(controlsArea);
                    progressElem.textContent = i18n.t('loading');
                        }

            try {
                        const finalJson = await ScraperHandler.buildConversationJson(platform, title, progressElem);
                const filename = `${platform}_${Utils.sanitizeFilename(title)}_${new Date().toISOString().slice(0, 10)}.json`;
                    await LyraCommunicator.open(JSON.stringify(finalJson, null, 2), filename);
            } catch (error) {
                        ErrorHandler.handle(error, 'Preview conversation', {
                            userMessage: `${i18n.t('loadFailed')} ${error.message}`
                        });
            } finally {
                Utils.restoreButton(btn, original);
                    if (progressElem) progressElem.remove();
                    }
                },
                    useInlineStyles
                );

            if (useInlineStyles) {
            Object.assign(previewBtn.style, {
                backgroundColor: buttonColor,
                    color: 'white'
                    });
                }
                controlsArea.appendChild(previewBtn);
            }

                const exportBtn = Utils.createButton(
                    `${exportIcon} ${i18n.t('exportCurrentJSON')}`,
                    async (btn) => {
                        const title = handler.getTitle();
                        if (!title) return;

                        const original = btn.innerHTML;
                        Utils.setButtonLoading(btn, i18n.t('exporting'));

                        let progressElem = null;
                        if (platform === 'aistudio') {
                            progressElem = Utils.createProgressElem(controlsArea);
                            progressElem.textContent = i18n.t('exporting');
                        }

                        try {
                            const finalJson = await ScraperHandler.buildConversationJson(platform, title, progressElem);
                            const filename = `${platform}_${Utils.sanitizeFilename(title)}_${new Date().toISOString().slice(0, 10)}.json`;
                            Utils.downloadJSON(JSON.stringify(finalJson, null, 2), filename);
                        } catch (error) {
                            ErrorHandler.handle(error, 'Export conversation');
                        } finally {
                            Utils.restoreButton(btn, original);
                            if (progressElem) progressElem.remove();
                        }
                    },
                    useInlineStyles
                );

                if (useInlineStyles) {
                    Object.assign(exportBtn.style, {
                        backgroundColor: buttonColor,
                        color: 'white'
                    });
                }
                controlsArea.appendChild(exportBtn);
            }
        };

    const UI = {

        injectStyle: () => {
            const platformColors = {
                claude: '#141413',
                chatgpt: '#10A37F',
                gemini: '#1a73e8',
                notebooklm: '#4285f4',
                aistudio: '#777779'
            };
            const buttonColor = platformColors[State.currentPlatform] || '#4285f4';
            console.log('[Lyra] Current platform:', State.currentPlatform);
            console.log('[Lyra] Button color:', buttonColor);
            document.documentElement.style.setProperty('--lyra-button-color', buttonColor);
            console.log('[Lyra] CSS variable --lyra-button-color set to:', buttonColor);
            const linkId = 'lyra-fetch-external-css';
                                    GM_addStyle(`
                #lyra-controls {
                    position: fixed !important;
                    top: 50% !important;
                    right: 0 !important;
                    transform: translateY(-50%) translateX(10px) !important;
                    background: white !important;
                    border: 1px solid #dadce0 !important;
                    border-radius: 8px !important;
                    padding: 16px 16px 8px 16px !important;
                    width: 136px !important;
                    z-index: 999999 !important;
                    font-family: 'Segoe UI', system-ui, -apple-system, sans-serif !important;
                    transition: all 0.7s cubic-bezier(0.4, 0, 0.2, 1) !important;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.15) !important;
                }

                #lyra-controls.collapsed {
                    transform: translateY(-50%) translateX(calc(100% - 35px + 6px)) !important;
                    opacity: 0.6 !important;
                    background: white !important;
                    border-color: #dadce0 !important;
                    border-radius: 8px 0 0 8px !important;
                    box-shadow: 0 4px 12px rgba(0,0,0,0.15) !important;
                    pointer-events: none !important;
                }
                #lyra-controls.collapsed .lyra-main-controls {
                    opacity: 0 !important;
                    pointer-events: none !important;
                }

                #lyra-controls:hover {
                    opacity: 1 !important;
                }

                #lyra-toggle-button {
                    position: absolute !important;
                    left: 0 !important;
                    top: 50% !important;
                    transform: translateY(-50%) translateX(-50%) !important;
                    cursor: pointer !important;
                    width: 32px !important;
                    height: 32px !important;
                    display: flex !important;
                    align-items: center !important;
                    justify-content: center !important;
                    background: #ffffff !important;
                    color: var(--lyra-button-color) !important;
                    border-radius: 50% !important;
                    box-shadow: 0 1px 3px rgba(0,0,0,0.2) !important;
                    border: 1px solid #dadce0 !important;
                    transition: all 0.7s cubic-bezier(0.4, 0, 0.2, 1) !important;
                    z-index: 1000 !important;
                    pointer-events: all !important;
                }

                #lyra-controls.collapsed #lyra-toggle-button {
                    z-index: 2 !important;
                    left: 16px !important;
                    transform: translateY(-50%) translateX(-50%) !important;
                    width: 21px !important;
                    height: 21px !important;
                    background: var(--lyra-button-color) !important;
                    color: white !important;
                }

                #lyra-controls.collapsed #lyra-toggle-button:hover {
                    box-shadow:
                        0 4px 12px rgba(0,0,0,0.25),
                        0 0 0 3px rgba(255,255,255,0.9) !important;
                    transform: translateY(-50%) translateX(-50%) scale(1.15) !important;
                    opacity: 0.9 !important;
                }

                .lyra-main-controls {
                    margin-left: 0px !important;
                    padding: 0 3px !important;
                    transition: opacity 0.7s !important;
                }

                .lyra-title {
                    font-size: 16px !important;
                    font-weight: 700 !important;
                    color: #202124 !important;
                    text-align: center;
                    margin-bottom: 12px !important;
                    padding-bottom: 0px !important;
                    letter-spacing: 0.3px !important;
                }

                .lyra-input-trigger {
                    display: flex !important;
                    align-items: center !important;
                    justify-content: center !important;
                    gap: 3px !important;
                    font-size: 10px !important;
                    margin: 10px auto 0 auto !important;
                    padding: 2px 6px !important;
                    border-radius: 3px !important;
                    background: transparent !important;
                    cursor: pointer !important;
                    transition: all 0.15s !important;
                    white-space: nowrap !important;
                    color: #5f6368 !important;
                    border: none !important;
                    font-weight: 500 !important;
                    width: fit-content !important;
                }

                .lyra-input-trigger:hover {
                    background: #f1f3f4 !important;
                    color: #202124 !important;
                }

                .lyra-button {
                    display: flex !important;
                    align-items: center !important;
                    justify-content: flex-start !important;
                    gap: 8px !important;
                    width: 100% !important;
                    padding: 8px 12px !important;
                    margin: 8px 0 !important;
                    border: none !important;
                    border-radius: 6px !important;
                    background: var(--lyra-button-color) !important;
                    color: white !important;
                    font-size: 11px !important;
                    font-weight: 500 !important;
                    cursor: pointer !important;
                    letter-spacing: 0.3px !important;
                    height: 32px !important;
                    box-sizing: border-box !important;
                }
                .lyra-button svg {
                    width: 16px !important;
                    height: 16px !important;
                    flex-shrink: 0 !important;
                }
                .lyra-button:disabled {
                    opacity: 0.6 !important;
                    cursor: not-allowed !important;
                }

                .lyra-status {
                    font-size: 10px !important;
                    padding: 6px 8px !important;
                    border-radius: 4px !important;
                    margin: 4px 0 !important;
                    text-align: center !important;
                }
                .lyra-status.success {
                    background: #e8f5e9 !important;
                    color: #2e7d32 !important;
                    border: 1px solid #c8e6c9 !important;
                }
                .lyra-status.error {
                    background: #ffebee !important;
                    color: #c62828 !important;
                    border: 1px solid #ffcdd2 !important;
                }

                .lyra-toggle {
                    display: flex !important;
                    align-items: center !important;
                    justify-content: space-between !important;
                    font-size: 11px !important;
                    font-weight: 500 !important;
                    color: #5f6368 !important;
                    margin: 3px 0 !important;
                    gap: 8px !important;
                    padding: 4px 8px !important;
                }

                .lyra-toggle:last-of-type {
                    margin-bottom: 14px !important;
                }

                .lyra-switch {
                    position: relative !important;
                    display: inline-block !important;
                    width: 32px !important;
                    height: 16px !important;
                    flex-shrink: 0 !important;
                }
                .lyra-switch input {
                    opacity: 0 !important;
                    width: 0 !important;
                    height: 0 !important;
                }
                .lyra-slider {
                    position: absolute !important;
                    cursor: pointer !important;
                    top: 0 !important;
                    left: 0 !important;
                    right: 0 !important;
                    bottom: 0 !important;
                    background-color: #ccc !important;
                    transition: .3s !important;
                    border-radius: 34px !important;
                    --theme-color: var(--lyra-button-color);
                }
                .lyra-slider:before {
                    position: absolute !important;
                    content: "" !important;
                    height: 12px !important;
                    width: 12px !important;
                    left: 2px !important;
                    bottom: 2px !important;
                    background-color: white !important;
                    transition: .3s !important;
                    border-radius: 50% !important;
                }
                input:checked + .lyra-slider {
                    background-color: var(--theme-color, var(--lyra-button-color)) !important;
                }
                input:checked + .lyra-slider:before {
                    transform: translateX(16px) !important;
                }

                .lyra-loading {
                    display: inline-block !important;
                    width: 14px !important;
                    height: 14px !important;
                    border: 2px solid rgba(255, 255, 255, 0.3) !important;
                    border-radius: 50% !important;
                    border-top-color: #fff !important;
                    animation: lyra-spin 0.8s linear infinite !important;
                }
                @keyframes lyra-spin {
                    to { transform: rotate(360deg); }
                }

                .lyra-progress {
                    font-size: 10px !important;
                    color: #5f6368 !important;
                    margin-top: 4px !important;
                    text-align: center !important;
                    padding: 4px !important;
                    background: #f8f9fa !important;
                    border-radius: 4px !important;
                }

                .lyra-lang-toggle {
                    display: flex !important;
                    align-items: center !important;
                    justify-content: center !important;
                    gap: 3px !important;
                    font-size: 10px !important;
                    margin: 4px auto 0 auto !important;
                    padding: 2px 6px !important;
                    border-radius: 3px !important;
                    background: transparent !important;
                    cursor: pointer !important;
                    transition: all 0.15s !important;
                    white-space: nowrap !important;
                    color: #5f6368 !important;
                    border: none !important;
                    font-weight: 500 !important;
                    width: fit-content !important;
                }
                .lyra-lang-toggle:hover {
                    background: #f1f3f4 !important;
                    color: #202124 !important;
                }
            `);
        },

        toggleCollapsed: () => {
            State.isPanelCollapsed = !State.isPanelCollapsed;
            localStorage.setItem('lyraExporterCollapsed', State.isPanelCollapsed);
            const panel = document.getElementById(Config.CONTROL_ID);
            const toggle = document.getElementById(Config.TOGGLE_ID);
            if (!panel || !toggle) return;
            if (State.isPanelCollapsed) {
                panel.classList.add('collapsed');
                safeSetInnerHTML(toggle, collapseIcon);
            } else {
                panel.classList.remove('collapsed');
                safeSetInnerHTML(toggle, expandIcon);
            }
        },

        recreatePanel: () => {
            document.getElementById(Config.CONTROL_ID)?.remove();
            State.panelInjected = false;
            UI.createPanel();
        },

        createPanel: () => {
            if (document.getElementById(Config.CONTROL_ID) || State.panelInjected) return false;

            const container = document.createElement('div');
            container.id = Config.CONTROL_ID;

            // 修复easychat不加载配色（就近生效）
            const color = getComputedStyle(document.documentElement)
            .getPropertyValue('--lyra-button-color')
            .trim() || '#141413';
            container.style.setProperty('--lyra-button-color', color);

            if (State.isPanelCollapsed) container.classList.add('collapsed');

            if (State.currentPlatform === 'notebooklm' || State.currentPlatform === 'gemini') {
                Object.assign(container.style, {
                    position: 'fixed',
                    top: '50%',
                    right: '0',
                    transform: 'translateY(-50%) translateX(10px)',
                    background: 'white',
                    border: '1px solid #dadce0',
                    borderRadius: '8px',
                    padding: '16px 16px 8px 16px',
                    width: '136px',
                    zIndex: '999999',
                    fontFamily: "'Segoe UI', system-ui, -apple-system, sans-serif",
                    transition: 'all 0.7s cubic-bezier(0.4, 0, 0.2, 1)',
                    boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
                    boxSizing: 'border-box'
                });
            }

            const toggle = document.createElement('div');
            toggle.id = Config.TOGGLE_ID;
            safeSetInnerHTML(toggle, State.isPanelCollapsed ? collapseIcon : expandIcon);
            toggle.addEventListener('click', UI.toggleCollapsed);
            container.appendChild(toggle);

            const controls = document.createElement('div');
            controls.className = 'lyra-main-controls';

            if (State.currentPlatform === 'notebooklm' || State.currentPlatform === 'gemini') {
                Object.assign(controls.style, {
                    marginLeft: '0px',
                    padding: '0 3px',
                    transition: 'opacity 0.7s'
                });
            }

            const title = document.createElement('div');
            title.className = 'lyra-title';
            const titles = { claude: 'Claude', chatgpt: 'ChatGPT', gemini: 'Gemini', notebooklm: 'Note LM', aistudio: 'AI Studio' };
            title.textContent = titles[State.currentPlatform] || 'Exporter';
            controls.appendChild(title);

            if (State.currentPlatform === 'claude') {
                ClaudeHandler.addUI(controls);
                ClaudeHandler.addButtons(controls);

                const inputLabel = document.createElement('div');
                inputLabel.className = 'lyra-input-trigger';
                inputLabel.textContent = `${i18n.t('manualUserId')}`;
                inputLabel.addEventListener('click', () => {
                    const newId = prompt(i18n.t('enterUserId'), State.capturedUserId);
                    if (newId?.trim()) {
                        State.capturedUserId = newId.trim();
                        localStorage.setItem('lyraClaudeUserId', State.capturedUserId);
                        alert(i18n.t('userIdSaved'));
                        UI.recreatePanel();
                    }
                });
                controls.appendChild(inputLabel);
            } else if (State.currentPlatform === 'chatgpt') {
                ChatGPTHandler.addUI(controls);
                ChatGPTHandler.addButtons(controls);
            } else {
                ScraperHandler.addButtons(controls, State.currentPlatform);
            }

            const langToggle = document.createElement('div');
            langToggle.className = 'lyra-lang-toggle';
            langToggle.textContent = `🌐 ${i18n.getLanguageShort()}`;
            langToggle.addEventListener('click', () => {
                i18n.setLanguage(i18n.currentLang === 'zh' ? 'en' : 'zh');
                UI.recreatePanel();
            });
            controls.appendChild(langToggle);

            container.appendChild(controls);
            document.body.appendChild(container);
            State.panelInjected = true;

            const panel = document.getElementById(Config.CONTROL_ID);
            if (State.isPanelCollapsed) {
                panel.classList.add('collapsed');
                safeSetInnerHTML(toggle, collapseIcon);
            } else {
                panel.classList.remove('collapsed');
                safeSetInnerHTML(toggle, expandIcon);
            }

            return true;
        }
    };

    const init = () => {
        if (!State.currentPlatform) return;

        if (State.currentPlatform === 'claude') ClaudeHandler.init();
        if (State.currentPlatform === 'chatgpt') ChatGPTHandler.init();

        UI.injectStyle();

        const initPanel = () => {
            UI.createPanel();
            if (State.currentPlatform === 'claude' || State.currentPlatform === 'chatgpt') {
                let lastUrl = window.location.href;
                new MutationObserver(() => {
                    if (window.location.href !== lastUrl) {
                        lastUrl = window.location.href;
                        setTimeout(() => {
                            if (!document.getElementById(Config.CONTROL_ID)) {
                                UI.createPanel();
                            }
                        }, 1000);
                    }
                }).observe(document.body, { childList: true, subtree: true });
            }
        };

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => setTimeout(initPanel, Config.TIMING.PANEL_INIT_DELAY));
        } else {
            setTimeout(initPanel, Config.TIMING.PANEL_INIT_DELAY);
        }
    };


        init();
    })();