export interface AudioPromptEntry {
  audio: string;
  lang: "ja" | "en";
  text: string;
  prompt?: string;
}

export interface AudioPromptsData {
  entries: AudioPromptEntry[];
}

export interface SceneData {
  scene: number;
  text: string;
}

export interface ScenePrompt {
  scene: number;
  filename: string;
  prompt: string;
}

export interface ImagePrompts {
  cover: string;
  scenes: ScenePrompt[];
}

export interface TextData {
  ja: string;
  en: string;
  duration: number;
  audio: string;
}

export interface PageData {
  texts: TextData[];
  image: string;
}

export interface ChoiceData {
  ja: string;
  en: string;
  correct: boolean;
  audio: string;
}

export interface QuestionData {
  ja: string;
  en: string;
  duration: number;
  answerDuration: number;
  audio: string;
  image: string;
  choices: ChoiceData[];
}

export interface BookData {
  title: string;
  pages: PageData[];
  questions: QuestionData[];
}

export interface MetaData {
  id: string;
  version: string;
  title: { ja: string; en: string };
  categoryId: string;
  categoryName: { ja: string; en: string };
}

export interface PageInfo {
  scene: string;
  jaText: string;
}
