<template>
  <div class="float-left" v-if="init">
    <div class="float-left mb-15">
      <div class="float-left helper-label mb-10">
        <span class="c-red">*</span>
        <span class="ml-5">试题内容</span>
      </div>
      <div class="float-left">
        <quill-editor
          class="quill-content"
          :is-formula="true"
          :height="40"
          v-model="form.content"
          mode="question"
        ></quill-editor>
      </div>
    </div>

    <div class="float-left mb-15" v-for="(i, index) in length" :key="i">
      <div class="d-flex">
        <div class="helper-label">
          <span class="c-red">*</span>
          <span class="ml-5">空{{ i }}答案</span>
        </div>
        <div class="flex-1 ml-10">
          <el-input
            class="w-400px"
            placeholder="答案"
            v-model="answers[index].a"
            @change="checkAnswers"
          ></el-input>
          <span style="font-size: 14px" class="c-red ml-10">*</span>
          <span class="helper-label ml-5">分数</span>
          <el-input
            type="number"
            class="w-200px ml-10"
            placeholder="分数"
            @change="checkAnswers"
            v-model="answers[index].s"
          ></el-input>
        </div>
      </div>
    </div>

    <div class="float-left mb-15">
      <el-link type="primary" @click="inc">增加一个空</el-link>
      <el-link class="ml-10" type="danger" v-if="length > 1" @click="dec">
        删除一个空
      </el-link>
    </div>

    <div class="float-left">
      <div class="float-left helper-label mb-10">解析</div>
      <div class="float-left">
        <quill-editor
          class="quill-content"
          :is-formula="true"
          :height="40"
          v-model="form.remark"
          mode="question"
        ></quill-editor>
      </div>
    </div>
  </div>
</template>

<script>
import QuillEditor from "@/components/quill-editor";

export default {
  components: {
    QuillEditor,
  },
  props: ["question", "index"],
  data() {
    return {
      init: false,
      length: 1,
      form: {
        score: null,
        content: null,
        answer: null,
        remark: null,
      },
      answers: [
        {
          a: null,
          s: null,
        },
      ],
    };
  },
  watch: {
    "form.score"() {
      this.update();
    },
    "form.content"() {
      this.update();
    },
    "form.answer"() {
      this.update();
    },
    "form.remark"() {
      this.update();
    },
  },
  mounted() {
    if (this.question) {
      Object.assign(this.form, this.question);

      // 解析答案
      if (this.form.answer && this.form.answer.substring(0, 5) === "v2:::") {
        this.answers = JSON.parse(this.form.answer.slice(5));
        this.length = this.answers.length;
        this.checkAnswers();
      }
    }

    this.init = true;
  },
  methods: {
    checkAnswers() {
      let data = [];
      let score = 0;
      for (let i = 0; i < this.length; i++) {
        data.push(this.answers[i]);
        if (!this.answers[i].s) {
          score = 0;
          break;
        } else if (parseInt(this.answers[i].s) === 0) {
          score = 0;
          break;
        } else if (parseInt(this.answers[i].s) > 0) {
          score += parseInt(this.answers[i].s);
        }
      }
      this.form.answer = data;
      if (score > 0) {
        this.form.score = score;
      } else {
        this.form.score = null;
      }
    },
    update() {
      this.$emit("change", this.form, this.index);
    },
    inc() {
      this.length += 1;
      this.answers.push({
        a: null,
        s: null,
      });
      this.checkAnswers();
    },
    dec() {
      if (this.length <= 1) {
        this.$message.warning("最少一个空");
        return;
      }
      this.answers.splice(this.length - 1, 1);
      this.length -= 1;
      this.checkAnswers();
    },
  },
};
</script>
