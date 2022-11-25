<template>
  <div class="quill-editor-box" :class="{ 'h-min-40': height === 40 }">
    <div ref="myQuillEditor" :style="style" class="quill-editor">
      <slot name="toolbar"></slot>
      <div ref="editor"></div>
    </div>
    <!--弹窗数据-->
    <el-dialog
      title="插入视频地址"
      :visible="dialogFormVisible"
      :show-close="false"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
    >
      <el-form :model="form">
        <el-form-item>
          <el-input
            v-model="form.videoIframe"
            placeholder="如：<iframe src=... ></iframe>"
            auto-complete="off"
          ></el-input>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogFormVisible = false">取 消</el-button>
        <el-button type="primary" @click="confirm()">确 定</el-button>
      </div>
    </el-dialog>
    <select-image
      :show="showUploadImage"
      :from="1"
      @close="showUploadImage = false"
      @selected="uploadImage"
    ></select-image>
    <el-dialog
      title="插入公式"
      :visible="dialogFormulaVisible"
      :show-close="false"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
    >
      <el-form :model="form">
        <el-form-item class="mb-15">
          <el-select v-model="formulaType">
            <el-option
              v-for="(item, index) in types"
              :key="index"
              :label="item.name"
              :value="item.id"
            >
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-input
            v-if="formulaType === 0"
            v-model="formulaValue"
            placeholder="如：x^2+y^2+Dx+Ey+F=0"
            auto-complete="off"
          ></el-input>
          <el-input
            v-else
            type="textarea"
            v-model="formulaValue"
            rows="4"
            resize="none"
            placeholder="如：x^2+y^2+Dx+Ey+F=0"
            auto-complete="off"
          ></el-input>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogFormulaVisible = false">取 消</el-button>
        <el-button type="primary" @click="confirmFormula()">确 定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import _Quill from "quill";
import katex from "katex";

import "quill/dist/quill.core.css";
import "quill/dist/quill.snow.css";
import "quill/dist/quill.bubble.css";
import "katex/dist/katex.css";

import debounce from "lodash/debounce";
import SelectImage from "@/components/select-image";

export default {
  components: {
    SelectImage,
  },
  props: ["value", "height", "mode", "isFormula"],
  data() {
    return {
      quill: null,
      dialogFormVisible: false,
      showUploadImage: false,
      dialogFormulaVisible: false,
      form: {
        videoIframe: "",
      },
      formulaValue: "",
      formulaType: 0,
      editorIndex: 0,
      editorOption: {
        theme: "snow",
        modules: {
          toolbar: this.toolbar(),
          formula: this.formula(),
        },
        placeholder: "请输入内容...",
        readOnly: false,
      },
      types: [
        {
          name: "单行公式",
          id: 0,
        },
        {
          name: "多行公式",
          id: 1,
        },
      ],
    };
  },
  computed: {
    style() {
      if (this.height !== 40) {
        return { height: (this.height || 300) + "px" };
      }
      return null;
    },
  },
  mounted() {
    window.katex = katex;
    this.init();
  },
  beforeDestroy() {
    this.quill = null;
    delete this.quill;
  },
  methods: {
    formula() {
      if (this.isFormula) {
        return true;
      } else {
        return false;
      }
    },
    toolbar() {
      if (this.mode && this.mode === "question") {
        if (this.isFormula) {
          return ["video", "image", "formula"];
        }
        return ["bold", "italic", "underline", "strike", "video", "image"];
      }
      if (this.mode && this.mode === "remark") {
        return [
          ["bold", "italic", "underline", "strike"],
          ["blockquote", "code-block"],
          [{ list: "ordered" }, { list: "bullet" }],
          [{ size: ["small", false, "large", "huge"] }],
          [{ header: [1, 2, 3, 4, 5, 6, false] }],
          [{ color: [] }, { background: [] }],
        ];
      }

      return [
        ["bold", "italic", "underline", "strike"],
        ["blockquote", "code-block"],
        [{ list: "ordered" }, { list: "bullet" }],
        [{ size: ["small", false, "large", "huge"] }],
        [{ header: [1, 2, 3, 4, 5, 6, false] }],
        [{ color: [] }, { background: [] }],
        [{ align: [] }],
        ["formula"],
        ["link", "video", "image"],
      ];
    },
    init() {
      this.quill = new _Quill(this.$refs["myQuillEditor"], this.editorOption);

      //禁用编辑器，防止页面自动滚动到编辑器位置
      this.quill.enable(false);
      // 初始值
      this.quill.pasteHTML(this.value || "");
      this.$nextTick(function () {
        //丢掉编辑器焦点并重新启用编辑器
        this.quill.blur();
        this.quill.enable(true);
      });

      // 自定义imageHandler
      this.quill.getModule("toolbar").addHandler("image", () => {
        this.showUploadImage = true;
      });
      // 自定义插入公式
      this.quill.getModule("toolbar").addHandler("formula", () => {
        this.dialogFormulaVisible = true;
      });

      //  自定义插入视频
      this.quill.getModule("toolbar").addHandler("video", () => {
        this.dialogFormVisible = true;
      });

      // 监听记录Index
      this.quill.on("selection-change", (range, oldRange) => {
        if (oldRange === null || oldRange.index === 0) {
          this.editorIndex = this.quill.getLength();
        } else {
          this.editorIndex = oldRange.index;
        }
      });

      // 值变化
      this.quill.on(
        "text-change",
        debounce(() => {
          let html = this.$refs.myQuillEditor.children[0].innerHTML;
          if (html === "<p><br></p>") {
            html = "";
          }
          this.onEditorChange(html);
        }, 400)
      );
    },
    onEditorChange(val) {
      this.$emit("input", val);
    },
    confirm() {
      this.quill.focus();
      if (!/^<iframe.+<\/iframe>$/.test(this.form.videoIframe)) {
        this.form.videoIframe = "";
        return;
      }
      var range = this.quill.getSelection();
      if (range) {
        //  在当前光标位置插入图片
        this.quill
          .getModule("toolbar")
          .quill.clipboard.dangerouslyPasteHTML(
            range.index,
            this.form.videoIframe
          );
        //  将光标移动到图片后面
        this.quill.getModule("toolbar").quill.setSelection(range.index + 1);
      }
      this.form.videoIframe = "";
      this.dialogFormVisible = false;
    },
    confirmFormula() {
      this.quill.focus();
      if (!this.formulaValue) {
        this.formulaValue = "";
        this.$message.error("请输入公式");
        return;
      }
      let value = this.formulaValue;
      if (this.formulaType === 1) {
        value = "$$" + value + "$$";
      } else {
        value = "$" + value + "$";
      }
      var range = this.quill.getSelection();
      if (range) {
        this.quill
          .getModule("toolbar")
          .quill.clipboard.dangerouslyPasteHTML(range.index, value);
        //  将光标移动到图片后面
        this.quill.getModule("toolbar").quill.setSelection(range.index + 1);
      }
      this.formulaValue = "";
      this.formulaType = 1;
      this.dialogFormulaVisible = false;
    },
    uploadImage(imgUrl) {
      let index = this.editorIndex;
      let nextIndex = this.editorIndex + 1;
      let html = this.$refs.myQuillEditor.children[0].innerHTML;
      if (html === "<p><br></p>") {
        index = 0;
        nextIndex = 1;
      }
      this.quill.insertEmbed(index, "image", imgUrl);
      this.quill.getModule("toolbar").quill.setSelection(nextIndex);
      this.showUploadImage = false;
    },
  },
};
</script>

<style lang="less" scoped>
.quill-editor-box {
  width: 100%;
  float: left;
}
</style>

<style lang="less">
.quill-editor-box {
  background-color: white;

  .ql-toolbar.ql-snow {
    border-top-left-radius: 4px;
    border-top-right-radius: 4px;
    border-color: #dcdfe6;
    .ql-picker-label {
      color: #ccc;
    }
    .ql-picker-label {
      color: #ccc;
    }
    .ql-active {
      color: #000;
    }
    .ql-stroke {
      stroke: #ccc;
    }
    .ql-fill {
      fill: #ccc;
    }
    .ql-picker.ql-expanded .ql-picker-options {
      z-index: 2001;
    }
  }

  .ql-container.ql-snow {
    border-bottom-left-radius: 4px;
    border-bottom-right-radius: 4px;
    border-color: #dcdfe6;
    font-size: 14px;
    color: #606266;
  }

  .ql-picker-label::before {
    position: absolute;
  }
  .ql-picker-label {
    svg {
      display: block;
    }
  }
  .ql-toolbar.ql-snow {
    padding: 0;
  }
  .ql-editor .ql-size-small {
    font-size: 0.75em;
  }
  .ql-editor .ql-size-large {
    font-size: 1.5em;
  }
  .ql-editor .ql-size-huge {
    font-size: 2.5em;
  }
  .ql-editor h1,
  .ql-editor h2,
  .ql-editor h3,
  .ql-editor h4,
  .ql-editor h5,
  .ql-editor h6 {
    margin-top: 8px;
    margin-bottom: 8px;
    padding: 0px;
    font-weight: bold;
    color: black;
  }
  .ql-editor ul,
  .ql-editor ol {
    margin-top: 8px;
    margin-bottom: 8px;
    padding-left: 15px;
    color: black;
  }
  .ql-editor ol li {
    counter-reset: myCounter;
    counter-increment: list-0;
  }
  .ql-editor ol li:not(.ql-direction-rtl)::before {
    counter-increment: myCounter;
    content: counter(myCounter) ". ";
    margin-left: -1.5em;
    margin-right: 0.3em;
    text-align: right;
  }
  .ql-editor p code,
  .ql-editor li code {
    font-size: 14px;
    word-wrap: break-word;
    padding: 2px 4px;
    border-radius: 4px;
    margin: 0 2px;
    color: #1e6bb8;
    background-color: rgba(27, 31, 35, 0.05);
    font-family: Operator Mono, Consolas, Monaco, Menlo, monospace;
    word-break: break-all;
  }
  .ql-editor sub,
  sup {
    line-height: 0;
  }
  .ql-editor {
    min-height: 80px;
    font-size: 16px;
    color: #333333;
    line-height: 30px;
    hr {
      height: 1px;
      margin: 0;
      margin-top: 5px;
      margin-bottom: 5px;
      border: none;
      border-top: 1px solid black;
    }
    em {
      font-style: italic;
      color: black;
    }
    img {
      display: block;
      margin: 0 auto;
      max-width: 100%;
      vertical-align: middle;
      border-style: none;
    }
    a {
      text-decoration: none;
      color: #1e6bb8;
      word-wrap: break-word;
      font-weight: bold;
      border-bottom: 1px solid #1e6bb8;
    }
    h1 {
      font-size: 2em;
    }
    h2 {
      font-size: 1.5em;
    }
    h3 {
      font-size: 1.17em;
    }
    h4 {
      font-size: 1em;
    }
    h5 {
      font-size: 0.83em;
    }
    h6 {
      font-size: 0.67em;
    }
    ul {
      list-style-type: disc;
      li {
        margin-top: 5px;
        margin-bottom: 5px;
        line-height: 26px;
        text-align: left;
        color: rgb(1, 1, 1);
        font-weight: 500;
      }
    }
    p {
      font-size: 16px;
      padding-top: 15px;
      padding-bottom: 15px;
      margin: 0;
      line-height: 30px;
      color: #333333;
    }
    strong {
      font-weight: bold;
      color: #333333;
    }
    figure {
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      margin: 0;
      margin-top: 5px;
      margin-bottom: 5px;
    }
    figcaption {
      margin-top: 5px;
      text-align: center;
      color: #888;
      font-size: 14px;
    }
    pre {
      padding: 0 4px;
    }
    blockquote {
      display: block;
      font-size: 1em;
      overflow: auto;
      overflow-scrolling: touch;
      border-left: 2px solid rgba(0, 0, 0, 0.4);
      background: rgba(0, 0, 0, 0.05);
      color: #6a737d;
      padding: 10px 15px;
      margin: 10px 0;

      p {
        margin: 0 !important;
        padding: 0;
      }
    }

    table {
      border: 1px solid #ccc;
      widows: 100%;
      margin: 0;
      padding: 0;
      border-collapse: collapse;
      border-spacing: 0;
      font-size: 16px;

      tr {
        border: 0;
        border-top: 1px solid #ccc;
        background-color: white;

        th {
          text-align: center;
          font-weight: bold;
          background-color: #f0f0f0;
          border: 1px solid #ccc;
        }

        td {
          text-align: center;
          border: 1px solid #ccc;
        }
      }
    }
  }
  .ql-editor[data-placeholder]::before {
    font-style: normal;
    font-size: 16px;
    color: #c0c4cc;
    padding-top: 15px;
  }

  &.h-min-40 {
    .ql-editor {
      min-height: 40px;
    }
  }
}
</style>
