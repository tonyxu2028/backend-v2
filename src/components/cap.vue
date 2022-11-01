<template>
  <div class="spbackground">
    <div v-if="previewImage" class="preview-image borderbox">
      <img
        class="back-detail"
        @click="backDetail()"
        src="../assets/img/icon-back-n.png"
      />
      <div class="pic-item">
        <div
          class="pic"
          :style="{ 'background-image': 'url(' + thumb + ')' }"
        ></div>
      </div>
    </div>
    <div class="info">
      <span class="tit"
        >{{ num }}.{{ question.type_text }}（{{ question.score }}分）</span
      >
    </div>
    <div class="question-content">
      <div class="content-render" v-latex>
        {{ question.content_transform.header_transform.text }}
      </div>
      <div
        class="images-render"
        v-if="
          question.content_transform.header_transform.images.length > 0 ||
          question.content_transform.header_transform.iframes.length > 0
        "
      >
        <template
          v-if="question.content_transform.header_transform.images.length > 0"
        >
          <div
            class="thumb-bar"
            v-for="(thumb, index) in question.content_transform.header_transform
              .images"
            :key="index + 'thumb'"
            @click="newPreviewImage(thumb)"
          >
            <thumb-bar
              :value="thumb"
              :width="200"
              :height="200"
              :border="8"
            ></thumb-bar>
          </div>
        </template>
        <template
          v-if="question.content_transform.header_transform.iframes.length > 0"
        >
          <div
            class="iframe-bar"
            v-for="(iframe, index) in question.content_transform
              .header_transform.iframes"
            :key="index + 'iframe'"
            v-html="iframe"
          ></div>
        </template>
      </div>
    </div>
    <div class="choice-box">
      <template v-for="(item, index) in questions">
        <div class="cap-item" :key="index">
          <template v-if="hasNotExists(index)">
            <!-- 单选 -->
            <question-choice
              v-if="item.type === 1"
              :num="index + 1"
              :question="item"
              :reply="null"
              :score="item.score"
              :is-correct="0"
              @update="questionUpdate"
              :is-over="isOver"
              :wrong-book="wrongBook"
            ></question-choice>

            <!-- 多选 -->
            <question-select
              v-else-if="item.type === 2"
              :num="index + 1"
              :question="item"
              :reply="null"
              :score="item.score"
              :is-correct="0"
              @update="questionUpdate"
              :is-over="isOver"
              :wrong-book="wrongBook"
            ></question-select>

            <!-- 填空 -->
            <question-input
              v-else-if="item.type === 3"
              :num="index + 1"
              :question="item"
              :reply="null"
              :score="item.score"
              :is-correct="0"
              @update="questionUpdate"
              :is-over="isOver"
              :wrong-book="wrongBook"
            ></question-input>

            <!-- 问答 -->
            <question-qa
              v-else-if="item.type === 4"
              :num="index + 1"
              :question="item"
              :reply="null"
              :thumbs="[]"
              :score="item.score"
              @update="questionUpdate"
              :show-image="showImage"
              :is-correct="0"
              :is-over="isOver"
              :wrong-book="wrongBook"
            ></question-qa>

            <!-- 判断 -->
            <question-judge
              v-else-if="item.type === 5"
              :num="index + 1"
              :question="item"
              :score="item.score"
              :is-correct="0"
              :reply="null"
              @update="questionUpdate"
              :is-over="isOver"
              :wrong-book="wrongBook"
            ></question-judge>
          </template>

          <template v-else>
            <!-- 单选 -->
            <question-choice
              v-if="item.type === 1"
              :num="index + 1"
              :question="item"
              :reply="answers[index].answer"
              :score="answers[index].score"
              @update="questionUpdate"
              :is-correct="answers[index].is_correct"
              :is-over="isOver"
              :wrong-book="wrongBook"
            ></question-choice>

            <!-- 多选 -->
            <question-select
              v-else-if="item.type === 2"
              :num="index + 1"
              :question="item"
              :reply="answers[index].answer_contents_rows"
              :score="answers[index].score"
              @update="questionUpdate"
              :is-correct="answers[index].is_correct"
              :is-over="isOver"
              :wrong-book="wrongBook"
            ></question-select>

            <!-- 填空 -->
            <question-input
              v-else-if="item.type === 3"
              :num="index + 1"
              :question="item"
              :reply="answers[index].answer_contents_rows"
              :score="answers[index].score"
              @update="questionUpdate"
              :is-correct="answers[index].is_correct"
              :is-over="isOver"
              :wrong-book="wrongBook"
            ></question-input>

            <!-- 问答 -->
            <question-qa
              v-else-if="item.type === 4"
              :num="index + 1"
              :question="item"
              :reply="answers[index].answer"
              :thumbs="answers[index]['thumbs']"
              :show-image="showImage"
              @update="questionUpdate"
              :score="answers[index].score"
              :is-correct="answers[index].is_correct"
              :is-over="isOver"
              :wrong-book="wrongBook"
            ></question-qa>

            <!-- 判断 -->
            <question-judge
              v-else-if="item.type === 5"
              :num="index + 1"
              :question="item"
              :score="answers[index].score"
              :is-correct="answers[index].is_correct"
              @update="questionUpdate"
              :reply="answers[index].answer_contents_rows"
              :is-over="isOver"
              :wrong-book="wrongBook"
            ></question-judge>
          </template>
        </div>
      </template>
    </div>
    <template v-if="isOver">
      <div class="analysis-box">
        <div class="answer-box">
          <div class="content">
            <div
              class="answer"
              v-if="question.answer && question.answer !== ''"
            >
              <i></i>答案：{{ question.answer }}
            </div>
            <div class="score" v-if="!wrongBook"><i></i>得分：{{ score }}</div>
          </div>
          <div
            class="button"
            v-if="question.remark && question.remark !== ''"
            @click="remarkStatus = !remarkStatus"
          >
            <span v-if="remarkStatus">折叠解析</span>
            <span v-else>展开解析</span>
            <img
              class="icon"
              v-if="remarkStatus"
              src="../assets/img/exam/fold.png"
            />
            <img class="icon" v-else src="../assets/img/exam/unfold.png" />
          </div>
        </div>
        <div
          class="remark-box"
          v-if="remarkStatus && question.remark && question.remark !== ''"
        >
          <div class="left-remark">
            <div class="tit"><i></i>解析：</div>
          </div>
          <div class="remark">
            <div class="content-render" v-latex>
              {{ question.remark_transform.text }}
            </div>
            <div
              class="images-render"
              v-if="
                question.remark_transform.images.length > 0 ||
                question.remark_transform.iframes.length > 0
              "
            >
              <template v-if="question.remark_transform.images.length > 0">
                <div
                  class="thumb-bar"
                  v-for="(thumb, index) in question.remark_transform.images"
                  :key="index + 'thumb'"
                  @click="newPreviewImage(thumb)"
                >
                  <thumb-bar
                    :value="thumb"
                    :width="200"
                    :height="200"
                    :border="8"
                  ></thumb-bar>
                </div>
              </template>
              <template v-if="question.remark_transform.iframes.length > 0">
                <div
                  class="iframe-bar"
                  v-for="(iframe, index) in question.remark_transform.iframes"
                  :key="index + 'iframe'"
                  v-html="iframe"
                ></div>
              </template>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>
<script>
import QuestionChoice from "./choice.vue";
import QuestionSelect from "./select.vue";
import QuestionInput from "./input.vue";
import QuestionQa from "./qa.vue";
import QuestionJudge from "./judge.vue";

export default {
  components: {
    QuestionChoice,
    QuestionSelect,
    QuestionInput,
    QuestionQa,
    QuestionJudge,
  },
  props: [
    "question",
    "reply",
    "isCorrect",
    "isOver",
    "score",
    "showImage",
    "wrongBook",
    "num",
  ],
  data() {
    return {
      header: null,
      questions: [],
      answers: [],
      previewImage: false,
      thumb: null,
      remarkStatus: false,
    };
  },
  mounted() {
    this.questionParse();
    this.replyParse();
    if (this.wrongBook) {
      this.remarkStatus = true;
    }
  },
  watch: {
    question() {
      this.questionParse();
    },
    reply() {
      this.replyParse();
    },
  },
  methods: {
    hasNotExists(index) {
      return typeof this.answers[index] === "undefined";
    },
    questionParse() {
      if (this.question) {
        let content = JSON.parse(this.question.content);

        // 题帽
        this.header = content.header;

        // 题目
        let questions = [];
        for (let i = 0; i < content.questions.length; i++) {
          let tmp = content.questions[i];
          tmp.id = this.question.id + "-cap-" + i;
          tmp.level_text = "";
          questions.push(tmp);
        }
        this.questions = questions;
      }
    },
    replyParse() {
      if (this.reply) {
        let content = this.reply;
        this.answers = content;
      }
    },
    questionUpdate(qid, answer, thumbs) {
      this.$emit("update", qid, answer, thumbs);
    },
    backDetail() {
      this.previewImage = false;
    },
    PreviewImage($event) {
      if ($event.target.src) {
        this.thumb = $event.target.src;
        this.previewImage = true;
      }
    },
    newPreviewImage(src) {
      this.thumb = src;
      this.previewImage = true;
    },
  },
};
</script>
<style lang="less" scoped>
.spbackground {
  background-color: #fff;
  width: 100%;
  float: left;
  height: auto;
  .preview-image {
    width: 100%;
    height: 100%;
    position: fixed;
    top: 0;
    left: 0;
    z-index: 400;
    padding: 15px;
    background-color: #000000;
    display: flex;
    align-items: center;
    .back-detail {
      position: absolute;
      top: 15px;
      left: 15px;
      width: 19px;
      height: 19px;
      cursor: pointer;
    }
    .pic-item {
      width: 100%;
      height: 100%;
      .pic {
        width: 100%;
        height: 100%;
        background-repeat: no-repeat;
        background-size: contain;
        background-position: center center;
      }
    }
  }
  .info {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 30px 30px 0px 30px;
    box-sizing: border-box;
    -moz-box-sizing: border-box;
    /* Firefox */
    -webkit-box-sizing: border-box;
    /* Safari */
    .tit {
      height: 18px;
      font-size: 18px;
      font-weight: 500;
      color: #333333;
      line-height: 18px;
    }
  }
  .question-content {
    width: 100%;
    float: left;
    height: auto;
    font-size: 15px;
    font-weight: 400;
    color: #333333;
    line-height: 24px;
    padding: 30px 30px 0px 30px;
    box-sizing: border-box;
    -moz-box-sizing: border-box;
    /* Firefox */
    -webkit-box-sizing: border-box;
    /* Safari */
    word-wrap: break-word;
  }
  .choice-box {
    width: 100%;
    height: auto;
    float: left;
    box-sizing: border-box;
    background-color: #fff;
    padding: 30px;
    .cap-item {
      width: 100%;
      display: flex;
      flex-direction: column;
      background-color: #fff;
      border-top: 1px dashed #ddd;
    }
  }
  .analysis-box {
    background-color: #fff;
  }
}
</style>
