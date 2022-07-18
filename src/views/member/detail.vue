<template>
  <div class="user-main-body" v-if="userData" v-loading="loading">
    <div class="float-left bg-white br-15 p-30">
      <back-bar class="mb-30" title="学员详情"></back-bar>
      <div class="user-info-box">
        <div class="user-base-info-box">
          <div class="user-avatar">
            <img :src="userData.avatar" width="80" height="80" />
          </div>
          <div class="user-nickname">{{ user.nick_name }}</div>
          <div class="buttons">
            <el-button
              type="primary"
              class="real-profile"
              @click="
                $router.push({ name: 'MemberProfile', params: { userId: id } })
              "
              >实名信息</el-button
            >
            <el-link
              type="primary"
              class="edit-profile"
              @click="
                $router.push({ name: 'MemberEdit', params: { userId: id } })
              "
            >
              修改资料
            </el-link>
            <p-link
              text="修改积分"
              type="primary"
              class="edit-profile"
              @click="
                $router.push({
                  name: 'MemberCredit1',
                  params: { userId: id },
                })
              "
              p="member.credit1.change"
            >
            </p-link>
            <p-link
              text="修改标签"
              type="primary"
              class="edit-profile"
              @click="
                $router.push({ name: 'MemberTag', params: { userId: id } })
              "
              p="member.tags"
            >
            </p-link>
            <p-link
              text="修改备注"
              type="primary"
              class="edit-profile"
              @click="
                $router.push({ name: 'MemberRemark', params: { userId: id } })
              "
              p="member.remark.update"
            >
            </p-link>
          </div>
        </div>
        <div class="panel-info-box">
          <div class="panel-info-item">ID：{{ userData.id }}</div>
          <div class="panel-info-item">手机号：{{ userData.mobile }}</div>
          <div class="panel-info-item">积分：{{ userData.credit1 }}</div>
          <div class="panel-info-item">
            VIP： {{ userData.role ? userData.role.name : "" }}
          </div>
          <div class="panel-info-item">
            VIP过期时间：{{ userData.role_expired_at | dateFormat }}
          </div>
          <div class="panel-info-item">
            一级邀请人：{{ userData.invitor ? userData.invitor.nick_name : "" }}
            <template v-if="userData.invitor">
              <div class="item">
                (有效期剩 {{ userData.invite_user_expired_at | dateFormat }}天)
              </div>
            </template>
          </div>
          <div class="panel-info-item">
            学员邀请码：{{
              userData.is_used_promo_code === 1 ? "已使用" : "未使用"
            }}
          </div>
          <div class="panel-info-item">
            推广余额：{{ userData.invite_balance }}
          </div>
          <div class="panel-info-item">
            锁定登录：{{ userData.is_lock === 1 ? "是" : "否" }}
          </div>
          <div class="panel-info-item">IP地址： {{ userData.register_ip }}</div>
          <div class="panel-info-item">
            注册区域： {{ userData.register_area }}
          </div>
          <div class="panel-info-item">
            标签：<template v-if="userData.tags">
              <el-tag class="mr-5" v-for="item in userData.tags" :key="item.id">
                {{ item.name }}
              </el-tag>
            </template>
          </div>
          <div class="panel-info-item">
            备注：<template v-if="userData.remark">
              <span v-html="userData.remark.remark"></span>
            </template>
          </div>
        </div>
      </div>
    </div>

    <!-- 学员课程区域 -->
    <div class="float-left bg-white br-15 p-30 mt-30">
      <el-tabs v-model="courseTabActive">
        <el-tab-pane
          :label="item.name"
          :name="item.key"
          v-for="item in courseTypes"
          :key="item.key"
        ></el-tab-pane>
      </el-tabs>

      <div class="float-left mt-30">
        <user-courses-comp
          :id="id"
          v-if="courseTabActive === 'vod'"
        ></user-courses-comp>
        <user-videos-comp
          :id="id"
          v-else-if="courseTabActive === 'video'"
        ></user-videos-comp>
        <user-orders-comp
          :id="id"
          v-else-if="courseTabActive === 'order'"
        ></user-orders-comp>
        <user-credit1-comp
          :id="id"
          v-else-if="courseTabActive === 'credit1'"
        ></user-credit1-comp>
        <user-roles-comp
          :id="id"
          v-else-if="courseTabActive === 'roles'"
        ></user-roles-comp>
        <user-invite-comp
          :id="id"
          v-else-if="courseTabActive === 'invite'"
        ></user-invite-comp>
        <user-vod-watch-records-comp
          :id="id"
          v-else-if="courseTabActive === 'vod-watch-records'"
        ></user-vod-watch-records-comp>
        <user-video-watch-records-comp
          :id="id"
          v-else-if="courseTabActive === 'video-watch-records'"
        ></user-video-watch-records-comp>
        <user-balance-records-comp
          :id="id"
          v-else-if="courseTabActive === 'balanceRecords'"
        ></user-balance-records-comp>
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";
import UserCoursesComp from "./detail/vod.vue";
import UserVideosComp from "./detail/video.vue";
import UserOrdersComp from "./detail/orders.vue";
import UserCredit1Comp from "./detail/credit1.vue";
import UserRolesComp from "./detail/roles.vue";
import UserInviteComp from "./detail/invite.vue";
import UserVodWatchRecordsComp from "./detail/vod-watch-records.vue";
import UserVideoWatchRecordsComp from "./detail/video-watch-records.vue";
import UserBalanceRecordsComp from "./detail/balanceRecords.vue";

export default {
  components: {
    UserCoursesComp,
    UserVideosComp,
    UserOrdersComp,
    UserCredit1Comp,
    UserRolesComp,
    UserInviteComp,
    UserVodWatchRecordsComp,
    UserVideoWatchRecordsComp,
    UserBalanceRecordsComp,
  },
  data() {
    return {
      id: null,
      userData: null,
      loading: false,
      courseTabActive: "vod",
    };
  },
  computed: {
    ...mapState(["user", "enabledAddons"]),
    courseTypes() {
      let types = [
        {
          name: "录播",
          key: "vod",
        },
        {
          name: "视频",
          key: "video",
        },
      ];

      // if (this.enabledAddons["Zhibo"]) {
      //   types.push({
      //     name: "直播",
      //     key: "live",
      //   });
      // }
      // if (this.enabledAddons["MeeduBooks"]) {
      //   types.push({
      //     name: "电子书",
      //     key: "books",
      //   });
      // }
      // if (this.enabledAddons["MeeduTopics"]) {
      //   types.push({
      //     name: "图文",
      //     key: "topics",
      //   });
      // }

      types.push(
        ...[
          {
            name: "录播观看",
            key: "vod-watch-records",
          },
          {
            name: "视频观看",
            key: "video-watch-records",
          },
          {
            name: "订单",
            key: "order",
          },
          {
            name: "积分明细",
            key: "credit1",
          },
          {
            name: "VIP记录",
            key: "roles",
          },
          {
            name: "邀请记录",
            key: "invite",
          },
        ]
      );
      if (
        this.enabledAddons["MultiLevelShare"] &&
        this.through("addons.MultiLevelShare.member.balanceRecords")
      ) {
        types.push({
          name: "邀请余额明细",
          key: "balanceRecords",
        });
      }

      return types;
    },
  },
  mounted() {
    this.id = this.$route.params.userId;

    this.getUser();
  },
  methods: {
    through(val) {
      return typeof this.user.permissions[val] !== "undefined";
    },
    getUser() {
      if (this.loading) {
        return;
      }
      this.loading = true;
      this.$api.Member.Detail(this.id).then((res) => {
        this.userData = res.data.data;
        this.loading = false;
      });
    },
  },
};
</script>

<style lang="less" scoped>
.user-main-body {
  width: 100%;
  height: auto;
  float: left;
}

.user-info-box {
  width: 100%;
  height: auto;
  float: left;
  box-sizing: border-box;
  display: flex;
  justify-content: center;
  margin-top: 10px;
  flex-direction: column;

  .user-base-info-box {
    width: 100%;
    height: auto;
    float: left;
    box-sizing: border-box;
    padding-bottom: 20px;
    border-bottom: 1px solid #f3f6f9;
    display: flex;
    flex-direction: row;

    .user-avatar {
      width: 80px;
      height: 80px;
      float: left;
      margin-right: 20px;
      img {
        width: 80px;
        height: 80px;
        border-radius: 50%;
      }
    }

    .user-nickname {
      width: auto;
      height: 80px;
      float: left;
      font-size: 20px;
      font-weight: 600;
      color: #333333;
      line-height: 80px;
    }
    .buttons {
      width: auto;
      height: 80px;
      float: left;
      display: flex;
      flex-direction: row;
      align-items: center;
      .real-profile {
        margin-right: 20px;
        margin-left: 30px;
      }
      .edit-profile {
        margin-right: 20px;
      }
    }
  }
  .panel-info-box {
    width: 100%;
    height: auto;
    float: left;
    box-sizing: border-box;
    padding-bottom: 20px;
    padding-top: 30px;
    display: grid;
    row-gap: 30px;
    column-gap: 0px;
    grid-template-columns: repeat(5, minmax(0, 1fr));
    .panel-info-item {
      display: flex;
      width: auto;
      height: auto;
      font-size: 14px;
      font-weight: 400;
      color: #333333;
      line-height: 14px;
      align-items: center;
      .item {
        flex: 1;
        line-height: 20px;
        margin-left: 5px;
      }
      span {
        display: inline-block;
      }
    }
  }
}

.user-extra-info-box {
  width: 100%;
  height: auto;
  float: left;
  box-sizing: border-box;
  padding: 30px;

  .info-label {
    font-weight: bold;
    color: #333;
    margin-right: 15px;
  }

  .info-value {
    color: rgba(0, 0, 0, 0.8);
  }
}
</style>
