import styleClasses from './docSum.module.scss'
import { Button, Text, Textarea, Title } from '@mantine/core'
import { FileUpload } from './FileUpload'
import { useEffect, useState } from 'react'
import Markdown from '../Shared/Markdown/Markdown'
import { fetchEventSource } from '@microsoft/fetch-event-source'
import { notifications } from '@mantine/notifications'
import { DOC_SUM_URL } from '../../config'
import { FileWithPath } from '@mantine/dropzone'


const DocSum = () => {
    const [isFile, setIsFile] = useState<boolean>(false);
    const [files, setFiles] = useState<FileWithPath[]>([])
    const [isGenerating, setIsGenerating] = useState<boolean>(false);
    const [value, setValue] = useState<string>('');
    const [fileContent, setFileContent] = useState<string>('');
    const [response, setResponse] = useState<string>('');
    
    useEffect(() => {
        if(isFile){
            setValue('')
        }
    },[isFile])

    useEffect(()=>{
        if (files.length) {
            const reader = new FileReader()
            reader.onload = async () => {
                const text = reader.result?.toString()
                setFileContent(text || '')
            };
            reader.readAsText(files[0])
        }
    },[files])

    
    const handleSubmit = async () => {
        setResponse("")
    if(!isFile && !value){
        notifications.show({
            color: "red",
            id: "input",
            message: "Please Upload Content",
        })
        return 
    }

    const formData = new FormData();
    formData.append("type", "text")
    formData.append("messages", isFile ? fileContent : value)
    formData.append("stream", "true")

    setIsGenerating(true)
    const body = formData

    fetchEventSource(DOC_SUM_URL, {
        method: "POST",
        headers: {
//             "Content-Type": "application/json",
            "Accept": "*/*"
        },
        body: body,
        openWhenHidden: true,
        async onopen(response) {
            if (response.ok) {
                return;
            } else if (response.status >= 400 && response.status < 500 && response.status !== 429) {
                const e = await response.json();
                console.log(e);
                throw Error(e.error.message);
            } else {
                console.log("error", response);
            }
        },

        async function* streamGenerator() {
          if (!response.body) {
            throw new Error("Response body is null");
          }
          const reader = response.body.getReader();
          const decoder = new TextDecoder("utf-8");
          let done, value;

          let buffer = ""; // Initialize a buffer

          while (({ done, value } = await reader.read())) {
            if (done) break;

            // Decode chunk and append to buffer
            const chunk = decoder.decode(value, { stream: true });
            buffer += chunk;

            // Use regex to clean and extract data
            const cleanedChunks = buffer
              .split("\n")
              .map((line) => {
                // Remove 'data: b' at the start and ' ' at the end
                return line.replace(/^data:\s*|^b'|'\s*$/g, "").trim(); // Clean unnecessary characters
              })
              .filter((line) => line); // Remove empty lines

            for (const cleanedChunk of cleanedChunks) {
              // Further clean to ensure all unnecessary parts are removed
              yield cleanedChunk.replace(/^b'|['"]$/g, ""); // Again clean 'b' and other single or double quotes
            }

            // If there is an incomplete message in the current buffer, keep it
            buffer = buffer.endsWith("\n") ? "" : cleanedChunks.pop() || ""; // Keep the last incomplete part
          }
        }

        onmessage(msg) {
            response = streamGenerator()
        },
        onerror(err) {
            console.log("error", err);
            setIsGenerating(false) 
            throw err;
        },
        onclose() {
           setIsGenerating(false) 
        },
    });
}


    return (
        <div className={styleClasses.docSumWrapper}>
            <div className={styleClasses.docSumContent}>
                <div className={styleClasses.docSumContentMessages}>
                    <div className={styleClasses.docSumTitle}>
                        <Title order={3}>Doc Summary</Title>
                    </div>
                    <div>
                        <Text size="lg" >Please upload file or paste content for summarization.</Text>
                    </div>
                    <div className={styleClasses.docSumContentButtonGroup}>
                        <Button.Group styles={{ group: { alignSelf: 'center' } }} >
                            <Button variant={!isFile ? 'filled' : 'default'} onClick={() => setIsFile(false)}>Paste Text</Button>
                            <Button variant={isFile ? 'filled' : 'default'} onClick={() => setIsFile(true)}>Upload File</Button>
                        </Button.Group>
                    </div>
                    <div className={styleClasses.docSumInput} >
                        {isFile ? (
                            <div className={styleClasses.docSumFileUpload}>
                                <FileUpload onDropAny={(files) => { setFiles(files) }} />
                            </div>
                        ) : (
                                <div className={styleClasses.docSumPasteText}>
                                <Textarea
                                    autosize
                                    autoFocus
                                    placeholder='Paste the text information you need to summarize'
                                    minRows={10}
                                    value={value}
                                    onChange={(event) => setValue(event.currentTarget.value)}
                                />
                            </div>
                        )}
                    </div>
                    <div>
                        <Button loading={isGenerating} loaderProps={{ type: 'dots' }} onClick={handleSubmit}>Generate Summary</Button>
                    </div>
                    {response && (
                        <div className={styleClasses.docSumResult}>
                            <Markdown content={response} />
                        </div>
                    )}
                    
                </div>
            </div>
        </div >
    )
}

export default DocSum
