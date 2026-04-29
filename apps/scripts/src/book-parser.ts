export interface AudioPromptEntry {
  audio: string;
  lang: "ja" | "en";
  text: string;
  prompt: string;
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

export interface PageInfo {
  scene: string;
  jaText: string;
}

export class BookParser {
  pagesFromBookData(book: BookData): PageInfo[] {
    return book.pages.map((page) => ({
      scene: page.image,
      jaText: page.texts.map((t) => t.ja).join(" "),
    }));
  }

  toXml(book: BookData): string {
    const lines: string[] = [
      '<?xml version="1.0" encoding="UTF-8"?>',
      "<ehon>",
    ];

    for (let pi = 0; pi < book.pages.length; pi++) {
      const page = book.pages[pi];
      lines.push("  <page>");
      for (const text of page.texts) {
        lines.push(
          `    <text duration="${text.duration}" audio="${text.audio}">`,
        );
        lines.push(`      <ja>${this.escape(text.ja)}</ja>`);
        lines.push(`      <en>${this.escape(text.en)}</en>`);
        lines.push("    </text>");
      }
      lines.push(`    <image>${page.image}</image>`);
      lines.push("  </page>");
    }

    lines.push("  <questions>");
    for (const q of book.questions) {
      lines.push(
        `    <question duration="${q.duration}" answer_duration="${q.answerDuration}" audio="${q.audio}">`,
      );
      lines.push("      <text>");
      lines.push(`        <ja>${this.escape(q.ja)}</ja>`);
      lines.push(`        <en>${this.escape(q.en)}</en>`);
      lines.push("      </text>");
      lines.push(`      <image>${q.image}</image>`);
      lines.push("      <choices>");
      for (const c of q.choices) {
        const correct = c.correct ? ' correct="true"' : "";
        lines.push(`        <choice${correct} audio="${c.audio}">`);
        lines.push(`          <ja>${this.escape(c.ja)}</ja>`);
        lines.push(`          <en>${this.escape(c.en)}</en>`);
        lines.push("        </choice>");
      }
      lines.push("      </choices>");
      lines.push("    </question>");
    }
    lines.push("  </questions>");
    lines.push("</ehon>");

    return lines.join("\n");
  }

  private escape(text: string): string {
    return text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }
}
