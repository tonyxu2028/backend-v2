<template>
  <div class="choice-item">
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
        {{ question.content_transform.text }}
      </div>
      <div
        class="images-render"
        v-if="
          question.content_transform.images.length > 0 ||
          question.content_transform.iframes.length > 0
        "
      >
        <template v-if="question.content_transform.images.length > 0">
          <div
            class="thumb-bar"
            v-for="(thumb, index) in question.content_transform.images"
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
        <template v-if="question.content_transform.iframes.length > 0">
          <div
            class="iframe-bar"
            v-for="(iframe, index) in question.content_transform.iframes"
            :key="index + 'iframe'"
            v-html="iframe"
          ></div>
        </template>
      </div>
    </div>
    <div class="choice-box">
      <div
        class="input-input-item"
        v-for="(item, index) of inputVal"
        :key="index"
      >
        <div class="name">
          填空{{ index + 1 }}（{{ questionAnswerRows[index].s }}分）：
        </div>
        <div class="input-box">
          <input
            :disabled="isOver"
            type="text"
            class="input"
            v-model="inputVal[index]"
            placeholder="请输入你的答案"
            @blur="change"
          />
        </div>
        <div class="icon-box" v-if="isOver">
          <img
            v-if="inputVal[index] === questionAnswerRows[index].a"
            class="icon"
            src="../assets/img/exam/icon-right.png"
          />
          <template v-else>
            <img class="icon" src="../assets/img/exam/icon-Wrong.png" />
            <div class="answer">答案：{{ questionAnswerRows[index].a }}</div>
          </template>
        </div>
      </div>
    </div>
    <template v-if="isOver">
      <div
        class="analysis-box"
        v-if="
          (wrongBook && question.remark && question.remark !== '') ||
          !wrongBook ||
          (remarkStatus && question.remark && question.remark !== '')
        "
      >
        <div
          class="answer-box"
          v-if="wrongBook && question.remark && question.remark !== ''"
        >
          <div class="button" @click="remarkStatus = !remarkStatus">
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
        <div class="answer-box" v-else-if="!wrongBook">
          <div class="content">
            <div class="score"><i></i>得分：{{ score }}</div>
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
export default {
  props: [
    "question",
    "reply",
    "isCorrect",
    "isOver",
    "score",
    "wrongBook",
    "num",
  ],
  data() {
    return {
      inputVal: [],
      previewImage: false,
      thumb: null,
      remarkStatus: false,
    };
  },
  computed: {
    inputLength() {
      if (typeof this.question.input_length !== "undefined") {
        return this.question.input_length;
      }

      if (typeof this.question.answer !== "undefined" && this.question.answer) {
        return this.question.answer.split(",").length;
      }

      return 0;
    },
    questionAnswerRows() {
      if (typeof this.question === "undefined") {
        return [];
      }

      if (typeof this.question.answer_transform === "undefined") {
        return [];
      }

      if (this.question.answer_transform) {
        return this.question.answer_transform;
      }

      return [];
    },
  },
  mounted() {
    let replyContent = this.reply || "";
    let replyRows = replyContent;

    for (let i = 0; i < this.inputLength; i++) {
      if (typeof replyRows[i] !== "undefined") {
        this.inputVal.push(replyRows[i]);
      } else {
        this.inputVal.push(null);
      }
    }
    if (this.wrongBook) {
      this.remarkStatus = true;
    }
  },
  methods: {
    change(e) {
      if (this.isOver) {
        return;
      }
      let val;
      if (e.target.value === "") {
        val = "";
      } else {
        val = this.inputVal;
      }
      this.$emit("update", this.question.id, val);
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
.choice-item {
  background-color: #f1f2f6;
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
    background-color: #fff;
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
    background-color: #fff;
    box-sizing: border-box;
    -moz-box-sizing: border-box;
    /* Firefox */
    -webkit-box-sizing: border-box;
    /* Safari */
  }
  .choice-box {
    width: 100%;
    height: auto;
    float: left;
    box-sizing: border-box;
    padding: 30px;
    background-color: #fff;
    .input-input-item {
      width: 100%;
      height: 40px;
      box-sizing: border-box;
      display: flex;
      flex-direction: row;
      align-items: center;
      margin-bottom: 30px;
      &:last-child {
        margin-bottom: 0px;
      }
      .name {
        height: 16px;
        font-size: 16px;
        font-weight: 400;
        color: #666666;
        line-height: 16px;
        margin-right: 0px;
      }
      .input-box {
        width: 200px;
        height: 40px;
        .input {
          width: 200px;
          height: 40px;
          border-radius: 4px;
          border: 1px solid #e5e5e5;
          padding-left: 20px;
          font-size: 14px;
          font-weight: 400;
          color: #666666;
          line-height: 24px;

          outline: none;
          background-color: #fff !important;
        }
        .input::-webkit-input-placeholder {
          color: #ccc;
        }
      }

      .icon-box {
        height: 40px;
        display: flex;
        align-items: center;
        margin-left: 15px;
        .icon {
          width: 20px;
          height: 20px;
        }
        .answer {
          margin-left: 10px;
          font-size: 14px;
          font-weight: 500;
          color: #333333;
          line-height: 24px;
        }
      }
    }
  }
}
</style>
